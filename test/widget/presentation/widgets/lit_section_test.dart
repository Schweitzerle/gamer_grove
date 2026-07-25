import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/widgets/sections/lit_section.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    bool reduceMotion = false,
    ScrollController? controller,
  }) async {
    // The viewport goes through the view, not through a MediaQuery wrapped
    // around MaterialApp — laying out for a size the surface does not have
    // leaves sections unbuilt and the assertions meaningless.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: GGTheme.dark(),
        builder: (context, child) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: Scaffold(
          body: ListView(
            controller: controller,
            children: [
              for (var i = 1; i <= 4; i++)
                LitSection(
                  title: 'Abschnitt $i',
                  onViewAll: () {},
                  child: SizedBox(height: 200, child: Text('Inhalt $i')),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The veil is the only thing that dims content, so its alpha is the number
  /// worth asserting on. Fails loudly when the section is not on screen: a
  /// helper that returns 0 for a missing section reports "fully lit" and hides
  /// the very thing under test.
  double veilAlpha(WidgetTester tester, String title) {
    final section = find.ancestor(
      of: find.text(title),
      matching: find.byType(LitSection),
    );
    expect(section, findsOneWidget, reason: '"$title" is not built');
    final veil = find.descendant(
      of: section,
      matching: find.byKey(LitSection.veilKey),
    );
    if (veil.evaluate().isEmpty) return 0;
    return tester.widget<ColoredBox>(veil).color.a;
  }

  testWidgets('a section near the middle is lit, one far away is not',
      (tester) async {
    await pumpPage(tester);

    // Section 1 sits near the top of the viewport, section 3 near the bottom,
    // so the first should be closer to full light than the third.
    expect(
      veilAlpha(tester, 'Abschnitt 1'),
      lessThan(veilAlpha(tester, 'Abschnitt 3')),
    );
  });

  testWidgets('scrolling moves the light with the page', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpPage(tester, controller: controller);

    final before = veilAlpha(tester, 'Abschnitt 1');
    controller.jumpTo(120);
    await tester.pumpAndSettle();

    // Scrolling down pushes section 1 towards the top edge, out of the light.
    expect(veilAlpha(tester, 'Abschnitt 1'), greaterThan(before));
  });

  testWidgets('dimming never goes past the point where text stays readable',
      (tester) async {
    await pumpPage(tester);

    for (var i = 1; i <= 3; i++) {
      expect(
        veilAlpha(tester, 'Abschnitt $i'),
        lessThanOrEqualTo(1 - LitSection.minLight + 0.001),
        reason: 'a section must not fade below the contrast floor',
      );
    }
  });

  testWidgets('reduced motion turns the lighting off entirely', (tester) async {
    await pumpPage(tester, reduceMotion: true);

    expect(veilAlpha(tester, 'Abschnitt 1'), 0);
    expect(find.text('Inhalt 1'), findsOneWidget);
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}
