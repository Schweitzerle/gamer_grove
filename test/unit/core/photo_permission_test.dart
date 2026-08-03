import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The broad media permission must not come back.
///
/// Google rejected a release over `READ_MEDIA_IMAGES`: an app targeting API 33
/// may only ask for it when a system picker cannot do the job. Ours can — the
/// one place the app opens a gallery is the profile picture, and the Android
/// photo picker returns exactly the one image the person chose, with no
/// permission at all.
///
/// A source check because the failure is a line in a manifest and a default in
/// a plugin. Both are invisible at runtime until a store review says no, and by
/// then the release is already rejected.
void main() {
  String read(String path) => File(path).readAsStringSync();

  test('the manifest asks for no broad media permission', () {
    final manifest = read('android/app/src/main/AndroidManifest.xml');
    for (final permission in const [
      'READ_MEDIA_IMAGES',
      'READ_MEDIA_VIDEO',
      'READ_MEDIA_VISUAL_USER_SELECTED',
    ]) {
      expect(
        manifest,
        isNot(contains('android.permission.$permission')),
        reason: 'Play refuses $permission where a system picker would do',
      );
    }
  });

  test('saving to the gallery keeps the write access it needs', () {
    // The other half of the same story: the download saves through `gal`,
    // which needs write access up to API 29 and nothing above it. Capped at 28
    // — as it was — saving to a named album fails on exactly API 29.
    final manifest = read('android/app/src/main/AndroidManifest.xml');
    expect(
      manifest,
      contains('WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"'),
    );
    expect(manifest, contains('android:requestLegacyExternalStorage="true"'));
  });

  test('nothing asks for a read permission in order to write a file', () {
    // The download used to request `Permission.photos` — read the whole
    // library — to save one image. That is what put the rejected permission in
    // the manifest in the first place.
    final offenders = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (file.readAsStringSync().contains('permission_handler')) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty,
        reason: 'these reach for permissions directly: $offenders');
  });

  test('the legacy storage permissions stay capped below Android 13', () {
    // These two are harmless only because they stop applying before the API
    // level the policy is about. Without the cap they are the same finding.
    final manifest = read('android/app/src/main/AndroidManifest.xml');
    for (final line in manifest.split('\n')) {
      if (!line.contains('READ_EXTERNAL_STORAGE') &&
          !line.contains('WRITE_EXTERNAL_STORAGE')) {
        continue;
      }
      expect(
        line,
        contains('android:maxSdkVersion'),
        reason: 'an uncapped storage permission reaches Android 13 and above',
      );
    }
  });

  test('the gallery is opened through one place that turns the picker on', () {
    // `useAndroidPhotoPicker` defaults to false, so calling ImagePicker
    // directly silently uses the legacy intent — the very thing that needs the
    // permission above.
    final picker = read('lib/core/media/profile_photo_picker.dart');
    expect(picker, contains('useAndroidPhotoPicker = true'));

    final offenders = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (file.path.endsWith('profile_photo_picker.dart')) continue;
      if (file.readAsStringSync().contains('ImagePicker()')) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'these open the gallery without the photo picker: $offenders',
    );
  });
}
