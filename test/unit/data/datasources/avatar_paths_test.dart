import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/supabase_auth_datasource_impl.dart';

/// Guards the path shape used when an account is deleted.
///
/// The storage policy on the avatars bucket matches the user id against the
/// FIRST path segment. Get that wrong and the delete is refused — the account
/// disappears while the photo stays in a public bucket, with nobody left who
/// is entitled to remove it. Exactly the state the deleted showcase account
/// left behind (two files, found 2026-08-06).
void main() {
  const uid = 'e661b5e3-2120-4ba6-af56-40c4f4eeeb91';

  test('puts the user id in the first segment', () {
    expect(avatarPathsFor(uid, ['avatar.png']), ['$uid/avatar.png']);
  });

  test('no leading slash — that would shift the id to segment two', () {
    final paths = avatarPathsFor(uid, ['avatar.png']);
    expect(paths.single.startsWith('/'), isFalse);
    expect(paths.single.split('/').first, uid);
  });

  test('covers every file in the folder, not just the first', () {
    // A user who changed format leaves both avatar.jpg and avatar.png behind.
    expect(
      avatarPathsFor(uid, ['avatar.jpg', 'avatar.png']),
      ['$uid/avatar.jpg', '$uid/avatar.png'],
    );
  });

  test('an empty folder asks for nothing', () {
    expect(avatarPathsFor(uid, []), isEmpty);
  });

  test('skips the placeholder row Supabase returns for an empty folder', () {
    // storage.list() on an empty prefix can yield a row with an empty name;
    // turning that into "uid/" would delete nothing and error.
    expect(avatarPathsFor(uid, ['', 'avatar.png']), ['$uid/avatar.png']);
  });
}
