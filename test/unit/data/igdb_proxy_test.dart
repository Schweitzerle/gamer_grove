import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The IGDB credentials must not come back into the app.
///
/// They lived in `Env` for as long as the client called IGDB directly, masked
/// by `envied`'s XOR — which ships the mask beside the masked bytes and so only
/// ever raised the effort of pulling them out. They are in the `igdb` edge
/// function now. This is a source check rather than a runtime one because the
/// failure it guards against is someone adding the field back, and that is
/// visible in the source long before it is visible anywhere else.
void main() {
  String read(String path) => File(path).readAsStringSync();

  test('no IGDB credential is declared in the app', () {
    for (final path in const [
      'lib/core/env/env.dart',
      'lib/core/env/env.g.dart',
      'lib/core/constants/api_constants.dart',
    ]) {
      final source = read(path);
      for (final forbidden in const [
        'IGDB_CLIENT_SECRET',
        'igdbClientSecret',
        'IGDB_CLIENT_ID',
        'igdbClientId',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: '$path declares $forbidden — it belongs in the edge '
              'function, not on every device',
        );
      }
    }
  });

  test('nothing in the app posts to IGDB directly', () {
    // The proxy is only worth anything if it is the single way out. One
    // datasource calling api.igdb.com again would need the credentials back.
    final offenders = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      if (source.contains('api.igdb.com')) offenders.add(file.path);
    }

    expect(
      offenders,
      isEmpty,
      reason: 'these still name the IGDB API directly: $offenders',
    );
  });

  test('the edge function refuses endpoints it was not asked for', () {
    // A passthrough proxy would forward any path to IGDB with our credentials
    // attached. The allowlist is the difference between a proxy and an open
    // relay, so its presence is worth asserting even from Dart.
    final function = read('supabase/functions/igdb/index.ts');
    expect(function, contains('const ALLOWED = new Set('));
    expect(function, contains('!ALLOWED.has(endpoint)'));
    expect(
      function,
      contains("Deno.env.get('IGDB_CLIENT_SECRET')"),
      reason: 'the secret must be read from the environment, never inlined',
    );
  });
}
