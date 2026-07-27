import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/cover_tint.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/widgets/sections/chamber_tint.dart';

/// The tint arrives late by nature — covers have to be fetched and decoded — so
/// what matters is that a section never appears, flickers, and settles.
void main() {
  setUp(CoverTint.clearCache);

  Future<Color> pumpTint(WidgetTester tester, List<String?> urls) async {
    late Color seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: GGTheme.dark(),
        home: Scaffold(
          body: ChamberTint(
            coverUrls: urls,
            builder: (context, tint) {
              seen = tint;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    return seen;
  }

  testWidgets('starts on the brand accent rather than on nothing',
      (tester) async {
    final tint = await pumpTint(tester, ['https://example.test/cover.jpg']);
    expect(tint, GGTheme.dark().colorScheme.primary);
  });

  testWidgets('a section without covers keeps the brand accent',
      (tester) async {
    expect(
      await pumpTint(tester, const []),
      GGTheme.dark().colorScheme.primary,
    );
    expect(
      await pumpTint(tester, const [null, '']),
      GGTheme.dark().colorScheme.primary,
    );
  });

  testWidgets('a cover that cannot be fetched leaves the accent in place',
      (tester) async {
    // No network in tests, so the fetch fails — which is exactly the case that
    // must not blank out or crash a section.
    final tint = await pumpTint(tester, ['https://example.invalid/x.jpg']);
    await tester.pump(const Duration(seconds: 2));
    expect(tint, GGTheme.dark().colorScheme.primary);
    expect(tester.takeException(), isNull);
  });

  testWidgets('asked for less motion, the tint is handed over without an ease',
      (tester) async {
    // The ease exists so a section does not appear and then change colour under
    // the reader. Cutting straight to the answer serves that too, and the
    // system asking for less motion is asking for exactly that.
    late Color seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: GGTheme.dark(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: ChamberTint(
              coverUrls: const [],
              builder: (context, tint) {
                seen = tint;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(seen, GGTheme.dark().colorScheme.primary);
    expect(find.byType(TweenAnimationBuilder<Color?>), findsNothing);
  });

  testWidgets('only the leading covers are read', (tester) async {
    // Every extra cover is another fetch and decode, and a row's light should
    // come from what is actually on screen.
    expect(ChamberTint.sampleCount, lessThanOrEqualTo(3));
  });
}
