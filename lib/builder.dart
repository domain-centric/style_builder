// Copyright (c) 2025 Nils ten Hoeve, licensed under the 3-Clause BSD License

// For inspiration, see:
// * https://pub.dev/packages/build
// * https://github.com/dart-lang/build/blob/master/docs/writing_a_builder.md
// * https://www.youtube.com/watch?v=mYDFOdl-aWM&t=459s

// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:style_builder/src/code/style_class_library.dart';
import 'package:style_builder/src/source_class.dart';
import 'package:build/build.dart';

Builder styleBuilder(BuilderOptions options) => StyleBuilder();

class StyleBuilder implements Builder {
  // Take a `.dart` file as input so that the Resolver has code to resolve
  @override
  final buildExtensions = const {
    '.dart': ['.g.dart'], // .g.dart is a common extension for generated files
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    var sourceClasses = <SourceClass>[];
    var entryLib = await buildStep.inputLibrary;
    var units = entryLib.units;
    for (var unit in units) {
      for (var classElement in unit.classes) {
        var sourceClass = createSourceClass(classElement);
        if (sourceClass != null) {
          sourceClasses.add(sourceClass);
        }
      }
    }
    if (sourceClasses.isNotEmpty) {
      var outputId = buildStep.inputId.changeExtension('.g.dart');

      StyleClassLibrary styleClassLibrary = StyleClassLibrary(sourceClasses);
      var formattedCode = Future.value(styleClassLibrary.toFormattedString());
      buildStep.writeAsString(outputId, formattedCode);
    }

    //  var resolver = buildStep.resolver;
    // // Get a `LibraryElement` for another asset.
    // var libFromAsset = await resolver.libraryFor(
    //     AssetId.resolve(Uri.parse('some_import.dart'),
    //     from: buildStep.inputId));
    // // Or get a `LibraryElement` by name.
    // var libByName = await resolver.findLibraryByName('my.library');
  }
}
