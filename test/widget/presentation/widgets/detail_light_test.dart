import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_detail_light.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';

void main() {
  /// The unit test proves the maths; this proves the maths is what actually
  /// ends up on screen. A wash painted at the wrong alpha, or over the content
  /// instead of under it, passes there and fails here.
  Widget litPage(ThemeData theme, Color tint) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          body: ColoredBox(
            color: theme.colorScheme.surface,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: DetailLight.reach,
                  child: DetailLight(tint: tint),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Standing in the brightest part',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  // The worst tint the cover extractor can hand over for each theme: the
  // brightest hue against the dark surface, the darkest against paper.
  const brightest = Color(0xFF858552); // yellow at S 0.38 / V 0.52
  const darkest = Color(0xFF525285); // blue at the same S and V

  final cases = {
    'dark': (GGTheme.dark(), brightest),
    'light': (GGTheme.light(), darkest),
  };

  for (final entry in cases.entries) {
    testWidgets('text over the light still meets contrast — ${entry.key}',
        (tester) async {
      final handle = tester.ensureSemantics();
      final (theme, tint) = entry.value;

      await tester.pumpWidget(litPage(theme, tint));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }

  testWidgets('the light takes no touches away from the content',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: GGTheme.dark(),
        home: Scaffold(
          body: Stack(
            children: [
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: DetailLight.reach,
                child: DetailLight(tint: Color(0xFF6B5285)),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () => tapped = true,
                  child: const Text('Add to collection'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add to collection'));
    expect(tapped, isTrue);
  });
}
