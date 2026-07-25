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
}
