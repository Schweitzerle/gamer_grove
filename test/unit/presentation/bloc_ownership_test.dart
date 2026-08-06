import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the rule that produced #171: whoever asks `sl` for a **factory**
/// bloc owns that instance and has to close it.
///
/// This is a source scan rather than a widget test on purpose. The leak is not
/// a behaviour a page exhibits — a leaked bloc looks exactly like a working one
/// until memory runs out — so there is nothing to assert against a pumped
/// widget. What can be asserted is the ownership rule itself, across every
/// call site at once, including the ones nobody thought to write a test for.
///
/// It is deliberately blunt: it checks that the file which took the instance
/// also mentions closing it. That accepts a file which closes some other bloc
/// on the same field name, and it will not notice a close that sits behind a
/// condition. It catches the case that actually occurred four times in this
/// codebase — a bloc taken and never closed anywhere.
void main() {
  test('every factory bloc taken from get_it is closed by its holder', () {
    final container = File('lib/injection_container.dart').readAsStringSync();

    // Singletons are excluded: get_it owns those for the process lifetime, and
    // closing one would hand every later caller a dead instance.
    final factoryBlocs =
        RegExp(r'registerFactory\s*\(\s*\(\)\s*=>\s*(\w+Bloc)\(')
            .allMatches(container)
            .map((m) => m.group(1)!)
            .toSet();

    expect(
      factoryBlocs,
      isNotEmpty,
      reason: 'Nothing matched — the registration style in '
          'injection_container.dart changed and this guard went blind.',
    );

    final leaks = <String>[];

    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();

      for (final match
          in RegExp(r'(\w+)\s*=\s*sl<(\w+Bloc)>\(\)').allMatches(source)) {
        final field = match.group(1)!;
        final type = match.group(2)!;
        if (!factoryBlocs.contains(type)) continue;

        // `BlocProvider(create: ...)` takes ownership and closes the bloc on
        // dispose, so a `create` callback returning it is already correct.
        final createdInsideProvider =
            RegExp(r'create:\s*\((?:_|\w+)\)\s*\{[^}]*?\b' + field + r'\b')
                .hasMatch(source);
        if (createdInsideProvider) continue;

        final closed =
            RegExp(RegExp.escape(field) + r'\??\.close\b').hasMatch(source);
        if (!closed) {
          leaks.add('${file.path}: $field ($type) is never closed');
        }
      }
    }

    expect(
      leaks,
      isEmpty,
      reason: 'A factory bloc is taken from get_it and never closed:\n'
          '${leaks.join('\n')}\n'
          'Close it in dispose(), or let BlocProvider(create:) own it.',
    );
  });
}
