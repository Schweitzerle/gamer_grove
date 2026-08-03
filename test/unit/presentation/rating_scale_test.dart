import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A rating is written on one scale and was read on three.
///
/// The slider in `rating_dialog.dart` runs 0.5 to 10 and that value goes
/// straight into `user_games.rating`, so ten is the scale a rating is *given*
/// on. `ColorScales.getRatingColor` bands at 90/80/60/40, so a hundred is the
/// scale a rating is *coloured* on. Three places applied the colour's
/// conversion to the label as well, and a 9.5 came out as "95.0" — once beside
/// a star, and once as the literal nonsense "95.0/10".
///
/// A source check rather than a widget test because the defect is a conversion
/// in the wrong place: it is visible in the line, and a rendered screen only
/// shows it to someone who knows what they rated.
void main() {
  String read(String path) => File(path).readAsStringSync();

  test('no label multiplies a user rating by ten', () {
    for (final path in const [
      'lib/presentation/widgets/sections/game_details_accordion.dart',
      'lib/presentation/pages/game_detail/widgets/user_states_section.dart',
      'lib/presentation/pages/activity_feed/widgets/activity_content.dart',
    ]) {
      final source = read(path);
      expect(
        source,
        isNot(contains('(userRating * 10).toStringAsFixed')),
        reason: '$path prints a 0-10 rating on a 0-100 scale',
      );
    }
  });

  test('the slider still writes the scale everything else assumes', () {
    // If this ever becomes 0..100 or 0..5, every reader above is wrong again
    // and the failure is silent.
    final dialog = read('lib/presentation/widgets/rating_dialog.dart');
    expect(dialog, contains('min: 0.5'));
    expect(dialog, contains('max: 10'));
  });

  test('the colour scale still reads a hundred', () {
    // The one place the multiplication belongs. Kept honest from the other
    // side: if the bands move to 0-10, the multiplications become the bug.
    final scales = read('lib/core/utils/colorSchemes.dart');
    expect(scales, contains('rating >= 90.0'));
    expect(scales, contains('rating >= 40.0'));
  });
}
