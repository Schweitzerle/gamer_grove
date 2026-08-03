import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/presentation/pages/user_search/widgets/user_search_item.dart';

import '../support/load_app_fonts.dart';

/// The row that lists a person, at the widths where it used to break.
///
/// It was reported as "the follow button sometimes overlaps". At 320 dp it
/// overflowed by 30 px and the name rendered at width zero; the "sometimes" was
/// only how long the name happened to be. These pin the two things that fixed
/// it — the row keeps its parts inside, and the button drops its label rather
/// than shoving the name out.
void main() {
  setUpAll(loadAppFonts);

  final user = User(
    id: 'u1',
    username: 'schweizerle',
    displayName: 'Julian',
    bio: 'Plays more RPGs than is reasonable.',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    totalGamesRated: 128,
    followersCount: 42,
    averageRating: 7.8,
  );

  Future<void> pump(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 300);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: GGTheme.dark(),
        home: Scaffold(
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 2,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => UserSearchItem(
              user: user,
              rank: index + 1,
              onFollowPressed: () {},
              isFollowing: index == 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  for (final width in const [320.0, 412.0]) {
    testWidgets('the person row at ${width.toInt()} dp', (tester) async {
      await pump(tester, width);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/user_row_${width.toInt()}.png'),
      );
    });
  }
}
