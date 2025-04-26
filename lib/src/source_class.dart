// Copyright (c) 2025 Nils ten Hoeve, licensed under the 3-Clause BSD License

// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:style_builder_annotation/style_builder_annotation.dart';

/// A [SourceClass] contains information of a class that:
/// * Is annotated with [GenerateThemeExtension]
/// * It is a public class
/// * It has a constructor that either:
///   * has no parameters (or default constructor)
///   * has a single parameter of type [BuildContext]
/// * It has one or more public fields that return a default cosmetic value.
class SourceClass {
  InterfaceType classType;
  String styleClassName;
  List<DefaultAccessor> defaultAccessors;
  SourceClass({required this.classType, required this.defaultAccessors})
    : styleClassName = _createName(classType);

  static String _createName(InterfaceType classType) =>
      '${classType.getDisplayString(withNullability: false).replaceAll(RegExp(r'Default$'), '')}Style';

  @override
  String toString() =>
      'SourceClass{classType: $classType,  defaultFields: $defaultAccessors, styleClassName: $styleClassName}';
}

/// Tries to create a [SourceClass]'s or logs information why classes are not valid.

SourceClass? createSourceClass(ClassElement classElement) {
  if (!_hasGenerateStyleClassAnnotation(classElement)) {
    return null;
  }
  if (!_hasValidConstructor(classElement)) {
    return null;
  }
  var classType = classElement.thisType;
  if (!_isValidSourceClassType(classType)) {
    return null;
  }
  var defaultAccessors = _createDefaultAccessors(classElement);
  if (defaultAccessors.isEmpty) {
    return null;
  }

  return SourceClass(classType: classType, defaultAccessors: defaultAccessors);
}

bool _hasValidConstructor(ClassElement classElement) {
  if (!classElement.constructors.any(
    (constructor) => _isValidConstructor(constructor),
  )) {
    log.warning(
      "Class ${classElement.name} must have an unnamed public constant constructor with no parameters",
    );
    return false;
  }
  return true;
}

bool _isValidConstructor(ConstructorElement element) {
  if (element.name.isNotEmpty) {
    return false;
  }
  if (!element.isPublic) {
    return false;
  }

  if (!element.isConst) {
    return false;
  }
  if (element.parameters.isNotEmpty) {
    return false;
  }
  return true;
}

List<DefaultAccessor> _createDefaultAccessors(ClassElement classElement) {
  var accessors = <DefaultAccessor>[
    ..._createDefaultFields(classElement),
    ..._createDefaultMethods(classElement),
  ];
  if (accessors.isEmpty) {
    log.warning(
      "Class ${classElement.thisType.element.name} must have at least one public field or method that returns a cosmetic default value",
    );
  }
  return accessors;
}

/// gets a default value
abstract class DefaultAccessor {
  final String name;
  final DartType type;

  DefaultAccessor({required this.name, required this.type});
}

class DefaultField extends DefaultAccessor {
  DefaultField({required super.name, required super.type});
}

bool _isValidDefaultField(FieldElement element) =>
    element.isPublic && element.type is! VoidType && !element.isStatic;

List<DefaultField> _createDefaultFields(ClassElement classElement) {
  var defaultFields = <DefaultField>[];
  for (var fieldElement in classElement.fields) {
    if (_isValidDefaultField(fieldElement)) {
      defaultFields.add(
        DefaultField(name: fieldElement.name, type: fieldElement.type),
      );
    }
  }
  return defaultFields;
}

class DefaultMethod extends DefaultAccessor {
  final bool hasBuildContextParameter;
  DefaultMethod({
    required super.name,
    required super.type,
    this.hasBuildContextParameter = false,
  });
}

bool _isValidDefaultMethod(MethodElement element) =>
    element.isPublic &&
    element.returnType is! VoidType &&
    !element.isStatic &&
    element.parameters.length <= 1 &&
    element.parameters.every(
      (parameter) => parameter.type.getDisplayString() == 'BuildContext',
    );

List<DefaultMethod> _createDefaultMethods(ClassElement classElement) {
  var defaultMethods = <DefaultMethod>[];
  for (var methodElement in classElement.methods) {
    if (_isValidDefaultMethod(methodElement)) {
      defaultMethods.add(
        DefaultMethod(
          name: methodElement.name,
          type: methodElement.returnType,
          hasBuildContextParameter: methodElement.parameters.length == 1,
        ),
      );
    }
  }
  return defaultMethods;
}

bool _isValidSourceClassType(InterfaceType classType) {
  if (classType.element.isPrivate) {
    log.warning("Class ${classType.element.name} may not be private");
    return false;
  }
  if (!classType.getDisplayString().endsWith('Default')) {
    log.warning(
      "Class ${classType.element.name} name should end with 'Default' to indicate it provides default values",
    );
  }
  return true;
}

bool _hasGenerateStyleClassAnnotation(ClassElement element) =>
    element.metadata.any(
      (annotation) => annotation.element?.displayName == "$GenerateStyleClass",
    );
