import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/presentation/pages/user_search/widgets/user_search_item.dart';

/// The row that lists a person — in search, in the leaderboard, and in
/// followers.
///
/// Reported from the device as "the follow button sometimes overlaps". It is
/// not sometimes: the width simply does not add up, and whether it shows
/// depends on how long the name is.
void main() {
  final user = User(
    id: 'u1',
    username: 'schweizerle',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    totalGamesRated: 128,
    followersCount: 42,
  );

  /// The leaderboard's own composition, so the test measures what ships and
  /// not a widget in isolation.
  /// Measured, not chosen: at 320 dp the row spends 32 on the list's padding,
  /// 32 on the card's, 52 on the avatar, 16 and 8 on gaps and about 70 on the
  /// button. What is left is a little over 100, and the name should get it.
  const nameFloor = 90.0;

  Widget leaderboardRow({User? person}) => MaterialApp(
        theme: GGTheme.dark(),
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              UserSearchItem(
                user: person ?? user,
                rank: 1,
                onFollowPressed: () {},
              ),
            ],
          ),
        ),
      );

  for (final width in const [320.0, 360.0, 412.0]) {
    testWidgets('the leaderboard row fits at ${width.toInt()} dp',
        (tester) async {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(leaderboardRow());
      await tester.pump();

      expect(
        tester.takeException(),
        isNull,
        reason: 'nothing in the row may overflow its box',
      );
    });
  }

  testWidgets('a long name gets the width that is left, not none',
      (tester) async {
    // A name squeezed to nothing is the same defect as an overflow, minus the
    // red stripe — and that is exactly what happened before: it rendered at
    // width zero while the button hung over the edge. A short name would pass
    // that test by being short, so this one is deliberately too long to fit and
    // asserts it still gets the room that is genuinely left over.
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      leaderboardRow(
        person: user.copyWith(username: 'a-name-far-too-long-for-this-row'),
      ),
    );
    await tester.pump();

    final name = tester.getSize(
      find.text('a-name-far-too-long-for-this-row'),
    );
    expect(
      name.width,
      greaterThan(nameFloor),
      reason: 'the name is the point of the row',
    );
  });

  testWidgets('survives 200 per cent text scale', (tester) async {
    // The row is dense — avatar, badge, name, handle, bio, three chips and a
    // button. Doubling the type is where a dense row breaks, and the threshold
    // that decides whether the button keeps its label scales with it for that
    // reason.
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: leaderboardRow(),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(leaderboardRow());
    await tester.pump();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
