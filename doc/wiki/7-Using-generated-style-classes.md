[//]: # (This file was generated from: doc/template/doc/wiki/7-Using-generated-style-classes.md.template using the documentation_builder package)

Use the static resolve method of the generated style class in your widget tree. 
It returns a record with none-nullable cosmetic values.
In example:
```dart
  MyCompanyStyle.resolve(context).tertiary
```

You can also add a style class as optional parameter. 
In example, you created MyWidget with a generated generated MyWidgetStyle class. You would use it as:
```dart
class MyWidget extends StatelessWidget {
  /// You can pass a custom style to the widget constructor,
  /// which will override default values
  final MyWidgetStyle? style;

  const MyWidget({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    // Resolve the style using the generated MyWidgetStyle class
    var resolvedStyle = MyWidgetStyle.resolve(context, style);
    /// return your implementation here, using resolvedStyle
  }
}
```