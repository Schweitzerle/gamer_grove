import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled brand fonts into the test binding.
///
/// Widget tests otherwise render every glyph in Flutter's placeholder font, so
/// a golden would prove nothing about the type system — the whole point of
/// stage 2. The files are read from disk rather than the asset bundle because
/// the test binding does not serve `pubspec.yaml` font declarations.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const families = <String, List<String>>{
    'BricolageGrotesque': ['assets/fonts/BricolageGrotesque-Bold.ttf'],
    'IBMPlexSans': [
      'assets/fonts/IBMPlexSans-Regular.ttf',
      'assets/fonts/IBMPlexSans-Medium.ttf',
      'assets/fonts/IBMPlexSans-SemiBold.ttf',
    ],
  };

  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      final file = File(path);
      if (!file.existsSync()) {
        throw StateError(
          'Missing font $path — goldens would silently fall back to the '
          'placeholder font and stop testing anything.',
        );
      }
      loader.addFont(
        file.readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
      );
    }
    await loader.load();
  }

  await _loadMaterialIcons();
}

/// Icons render as empty boxes in widget tests unless the icon font is loaded
/// explicitly — the asset bundle is not served to the test binding. Located via
/// the SDK rather than hardcoded, and skipped silently when it cannot be found,
/// so a golden run never fails over a missing developer-machine path.
Future<void> _loadMaterialIcons() async {
  // The test runs on the Dart VM inside the SDK, so walk up from it until the
  // Flutter cache turns up rather than guessing a fixed depth.
  for (var dir = File(Platform.resolvedExecutable).parent;
      dir.path != dir.parent.path;
      dir = dir.parent) {
    final file = File(
      '${dir.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (!file.existsSync()) continue;
    final loader = FontLoader('MaterialIcons')
      ..addFont(
        file.readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
      );
    await loader.load();
    return;
  }
}
