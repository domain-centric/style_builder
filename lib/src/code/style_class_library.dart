// Copyright (c) 2025 Nils ten Hoeve, licensed under the 3-Clause BSD License
import 'package:dart_code/dart_code.dart';
import 'package:style_builder/src/code/style_class.dart';
import 'package:style_builder/src/source_class.dart';

class StyleClassLibrary extends Library {
  StyleClassLibrary(List<SourceClass> sourceClasses)
    : super(
        classes: createStyleClasses(sourceClasses),
      );

  static List<Class> createStyleClasses(List<SourceClass> sourceClasses) => [
    for (var sourceClass in sourceClasses) StyleClass(sourceClass),
  ];

  
}
