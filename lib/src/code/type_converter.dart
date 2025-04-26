// Copyright (c) 2025 Nils ten Hoeve, licensed under the 3-Clause BSD License

// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/type.dart';
import 'package:dart_code/dart_code.dart';

/// Converts a [DartType] from the [analyzer] package
/// to a [Type] from the [dart_code] package.
Type toDartCodeType(DartType dartType, {bool nullable = false}) {
  var name = dartType.element!.displayName;
  var libraryUri = dartType.element?.library?.source.uri.toString();
  // To ensure that dart:core types are not imported, because they are already available in the SDK.
  if (libraryUri == 'dart:core') {
    libraryUri = null;
  }
  // prevent linter warnings for flutter types
  if (libraryUri != null &&
      libraryUri.startsWith('package:flutter/src/painting/')) {
    libraryUri = 'package:flutter/painting.dart';
  }
  return Type(name, libraryUri: libraryUri, nullable: nullable);
}
