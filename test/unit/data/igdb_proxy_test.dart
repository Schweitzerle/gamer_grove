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
    //
    // It lives in guard.ts since #161, together with the rest of the rules
    // that decide whether a request is served. The Deno tests next to it check
    // the behaviour; this one only checks that it still exists at all, from
    // the side that would otherwise never notice it going.
    final guard = read('supabase/functions/igdb/guard.ts');
    expect(guard, contains('export const ALLOWED = new Set('));
    expect(guard, contains('!ALLOWED.has(endpoint)'));

    expect(
      read('supabase/functions/igdb/index.ts'),
      contains("Deno.env.get('IGDB_CLIENT_SECRET')"),
      reason: 'the secret must be read from the environment, never inlined',
    );
  });

  test('the app sends a session token, not the anon key', () {
    // This is the whole of #161. The anon key is readable out of the APK and
    // sits in the public git history; sending it as the Authorization header
    // made the proxy a free IGDB API on our Twitch credentials.
    final source = read(
      'lib/data/datasources/remote/igdb/igdb_datasource_impl.dart',
    );

    expect(
      source,
      isNot(contains(r"'Authorization': 'Bearer ${Env.supabaseAnonKey}'")),
      reason: 'the anon key is not an identity',
    );
    expect(source, contains(r"'Authorization': 'Bearer $token'"));
    // apikey stays the anon key — that header is what the Supabase gateway
    // routes on, and it is public by design.
    expect(source, contains("'apikey': Env.supabaseAnonKey"));
  });

  test('the proxy asks the database who is calling', () {
    // Without this the function has no caller and no ceiling. The RPC does
    // both jobs in one round trip: PostgREST verifies the signature, the
    // function refuses a null auth.uid(), and the same call counts the hit.
    expect(
      read('supabase/functions/igdb/index.ts'),
      contains("rpc('igdb_rate_limit_hit')"),
    );
  });
}
