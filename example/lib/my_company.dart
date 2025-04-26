import 'dart:ui';

import 'package:style_builder_annotation/style_builder_annotation.dart';

/// This library demonstrates the use of the style_builder package to generate
/// a generic style class. The generated class provides a way to
/// define and resolve cosmetic properties. In this case it is a company style.

/// This class configures the generation of the [MyCompanyStyle] class.
/// It contains various cosmetic property types to demonstrate it working.
/// See the generated code for the [MyCompanyStyle] class in my_company.g.dart
///
/// Notes:
/// * The class is annotated with [GenerateStyleClass] to indicate that it
///   should be processed by the style_builder package.
/// * The class is a const class, which means it can be used as a compile-time constant.
/// * That cosmetic properties are defined by providing default values with either:
///   * none static final fields
///   * none static getter methods
///   * none static methods without parameters
///   * none static methods with a BuildContext parameter
@GenerateStyleClass()
class MyCompanyDefault {
  const MyCompanyDefault();
  final Color primary = const Color(0xFF7986CB); // Indigo
  final Color secondary = const Color(0xFF009688); // Teal
  final Color tertiary = const Color(0xFFFFC107); // Amber
}
