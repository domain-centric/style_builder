// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:dart_code/dart_code.dart';
import 'package:style_builder/src/code/type_converter.dart';
import 'package:style_builder/src/source_class.dart';

abstract class LerpExpressionFactory {
  /// Creates a lerp expression for the given type or returns null if the type is not supported.
  /// We assume that the type is already imported and that the class is public.
  Expression? createLerpExpression(DefaultAccessor accessor);
}

class LerpExpressionFactories implements LerpExpressionFactory {
  final List<LerpExpressionFactory> factories = [
    LerpFunctionExpressionFactory(),
    StaticMethodLerpExpressionFactory(),
  ];

  @override
  Expression? createLerpExpression(DefaultAccessor accessor) {
    for (var factory in factories) {
      var expression = factory.createLerpExpression(accessor);
      if (expression != null) {
        return expression;
      }
    }
    return null;
  }
}

/// Creates a expression for functions, e.g.: lerpDouble(a,b,t)
/// TODO allow to add others custom build functions via build.yaml
class LerpFunctionExpressionFactory implements LerpExpressionFactory {
  final List<SupportedLerpFunction> supportedFunctions = [
    SupportedLerpFunction(
      typeName: 'double',
      typeLibUri: null,
      functionName: 'lerpDouble',
      functionLibUri: 'dart:ui',
    ),
    SupportedLerpFunction(
      typeName: 'int',
      typeLibUri: null,
      functionName: 'lerpInt',
      functionLibUri: 'package:lerp/lerp.dart',
    ),
    SupportedLerpFunction(
      typeName: 'bool',
      typeLibUri: null,
      functionName: 'lerpBool',
      functionLibUri: 'package:lerp/lerp.dart',
    ),
    SupportedLerpFunction(
      typeName: 'Enum',
      typeLibUri: null,
      functionName: 'lerpEnum',
      functionLibUri: 'package:lerp/lerp.dart',
    ),
  ];

  @override
  Expression? createLerpExpression(DefaultAccessor accessor) {
    var type = toDartCodeType(accessor.type);
    if (accessor.type.element is EnumElement) {
      type = Type('Enum');
    }
    var function = supportedFunctions.firstWhereOrNull(
      (f) => f.supportsType(type),
    );
    if (function == null) {
      return null;
    }
    return Expression([
      FunctionCall(
        function.functionName,
        parameterValues: _createLerpMethodParameterValues(accessor),
        libraryUri: function.functionLibUri,
      ),
    ]);
  }
}

class SupportedLerpFunction {
  final String typeName;
  final String? typeLibUri;
  final String functionName;
  final String functionLibUri;

  const SupportedLerpFunction({
    required this.typeName,
    required this.typeLibUri,
    required this.functionName,
    required this.functionLibUri,
  });

  bool supportsType(Type type) =>
      type.name == typeName && type.libraryUri == typeLibUri;
}
// TODO remove if replaced with LerpFunctionExpressionFactory
// /// Creates a expression to lerp int's
// class IntLerpExpressionFactory implements LerpExpressionFactory {
//   @override
//   Expression? createLerpExpression(DefaultAccessor accessor) {
//     if (!accessor.type.isDartCoreInt) {
//       return null;
//     }
//     var a = accessor.name;
//     var b = 'other.${accessor.name}';
//     return Expression([
//       Code(
//         ' $a == null && $b == null ? null :'
//         ' $a == null ? ($b! * t).round() :'
//         ' $b == null ? ($a! * (1 - t)).round() :'
//         ' ($a! + ($b! - $a!) * t).round()',
//       ),
//     ]);
//   }
// }

/// Creates an expression for class methods with the following signature:
/// * are names lerp
/// * that are static
/// * have the same return type as the class
/// * have 3 parameters:
///   * the first parameter is the same type as the class
///   * the second parameter is the same type as the class
///   * the third parameter is a double
///
/// An example that complies: Color.lerp(a,b,t)
class StaticMethodLerpExpressionFactory implements LerpExpressionFactory {
  @override
  Expression? createLerpExpression(DefaultAccessor accessor) {
    if (!isSupportedType(accessor.type)) {
      return null;
    }
    return Expression.ofType(toDartCodeType(accessor.type)).callMethod(
      'lerp',
      parameterValues: _createLerpMethodParameterValues(accessor),
    );
  }

  bool isSupportedType(DartType type) {
    if (type is! InterfaceType) {
      return false;
    }
    if (type.element is! ClassElement) {
      return false;
    }
    var classElement = type.element as ClassElement;
    var type2 = toDartCodeType(type);
    for (var methodElement in classElement.methods) {
      if (isValidLerpMethod(type2, methodElement)) {
        return true;
      }
    }
    return false;
  }

  bool isValidLerpMethod(Type ownerType, MethodElement methodElement) =>
      methodElement.isStatic &&
      methodElement.name == 'lerp' &&
      methodElement.parameters.length == 3 &&
      _sameType(methodElement.parameters[0].type, ownerType) &&
      _sameType(methodElement.parameters[1].type, ownerType) &&
      methodElement.parameters[2].type.isDartCoreDouble &&
      _sameType(methodElement.returnType, ownerType);
}

bool _sameType(DartType type1, Type type2) {
  var type1b = toDartCodeType(type1);
  return type1b.name == type2.name && type1b.libraryUri == type2.libraryUri;
}

ParameterValues _createLerpMethodParameterValues(DefaultAccessor accessor) {
  return ParameterValues([
    ParameterValue(Expression.ofVariable(accessor.name)),
    ParameterValue(Expression.ofVariable('other').getProperty(accessor.name)),
    ParameterValue(Expression.ofVariable('t')),
  ]);
}

/// Creates a expression to lerp ThemeExtension's
/// TODO this does not work because the type of the DefaultAccessor is likely not known (still to be generated)
// class ThemeExtensionLerpExpressionFactory implements LerpExpressionFactory {
//   @override
//   Expression? createLerpExpression(DefaultAccessor accessor) {
//     if (!isThemeExtension(accessor.type)) {
//       return null;
//     }
//     var a = accessor.name;
//     var b = 'other.${accessor.name}';
//     return Expression([
//       Code(
//         '$a == null && $b == null ? null :'
//         '$a == null ? $b.lerp(null, t) :'
//         '$b == null ? $a.lerp(null, t) :'
//         '$a.lerp($b, t);',
//       ),
//     ]);
//   }

//   bool isThemeExtension(DartType type) {
//     var type2 = toDartCodeType(type);
//     return type2.name.startsWith('ThemeExtension') &&
//         type2.libraryUri == 'package:flutter/material.dart';
//   }
// }
