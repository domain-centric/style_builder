import 'package:example/my_widget.g.dart';
import 'package:flutter/material.dart';
import 'package:style_builder_annotation/style_builder_annotation.dart';

/// This library demonstrates the use of the style_builder package to generate
/// a style class for a [Widget]. The generated class provides a way to
/// define and resolve cosmetic properties of a [Widget].

/// This class configures the generation of the [MyWidgetStyle] class.
/// It contains various cosmetic property types to demonstrate it working.
/// See the generated code for the [MyWidgetStyle] class in my_widget.g.dart
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
class MyWidgetDefault {
  const MyWidgetDefault();

  final int borderRadius = 8;
  double get elevation => 4.0;
  EdgeInsets padding() => EdgeInsets.all(16.0);
  Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;
  Color shadow(BuildContext context) => Theme.of(context).colorScheme.shadow;
  TextStyle textStyle(BuildContext context) =>
      TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.onSurface);
}

/// This widget demonstrates how to use the generated [MyWidgetStyle] class
class MyWidget extends StatelessWidget {
  /// You can pass a custom style to the widget constructor,
  /// which will override the default
  final MyWidgetStyle? style;

  const MyWidget({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    // Resolve the style using the generated MyWidgetStyle class
    var resolvedStyle = MyWidgetStyle.resolve(context, style);
    return Container(
      padding: resolvedStyle.padding,
      decoration: BoxDecoration(
        color: resolvedStyle.surface,
        borderRadius: BorderRadius.circular(
          resolvedStyle.borderRadius.toDouble(),
        ),
        boxShadow: [
          BoxShadow(
            color: resolvedStyle.shadow,
            blurRadius: resolvedStyle.elevation,
          ),
        ],
      ),
      child: Text('Hello, World!', style: resolvedStyle.textStyle),
    );
  }
}
