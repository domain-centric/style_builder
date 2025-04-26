import 'package:example/my_company.g.dart';
import 'package:example/my_widget.dart';
import 'package:example/my_widget.g.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

/// Theme's are usually used for the whole application,
/// so you can override the style defaults for all widgets
/// of the same type.
ThemeData createTheme(Brightness brightness) => ThemeData(
  /// In this case we use MyCompanyStyle to generate the theme
  colorScheme: ColorScheme.fromSeed(
    seedColor: MyCompanyStyle.defaults.primary,
    secondary: MyCompanyStyle.defaults.secondary,
    brightness: brightness,
  ),
  // We could also override some other theme values
  appBarTheme: AppBarTheme(color: MyCompanyStyle.defaults.primary),

  /// You can optionally override the style class defaults
  /// in [ThemeData] by adding the generated style classes
  /// to the theme extensions.
  extensions: [MyWidgetStyle(borderRadius: 20)],
);

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: createTheme(Brightness.light),
    darkTheme: createTheme(Brightness.dark),
    themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
        title: const Text('style_builder example'),
      ),
      body: Center(
        child: MyWidget(
          /// You can optionally override the theme values for
          /// each widget by setting the style parameter to the
          /// widget constructor.
          ///
          /// The widget will use the defaults from the annotated
          /// class for style values that are not  overridden.
          style: MyWidgetStyle(
            elevation: 20,
            textStyle: TextStyle(
              fontSize: 18.0,
              color: MyCompanyStyle.resolve(context).tertiary,
            ),
          ),
        ),
      ),
    ),
  );
}
