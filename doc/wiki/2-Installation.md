[//]: # (This file was generated from: doc/template/doc/wiki/2-Installation.md.template using the documentation_builder package)

Make sure to add these packages to the project dependencies:

- [build_runner] tool to run code generators (dev dependency)
- [style_builder] this package (dev dependency)
- [style_builder_annotation] annotations for [style_builder]

From the command line:
```bash
flutter pub add --dev build_runner
flutter pub add --dev style_builder
flutter pub add style_builder_annotation
```