import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/navigation/gg_reveal_route.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';

void main() {
  final navigator = GlobalKey<NavigatorState>();
  const origin = Rect.fromLTWH(20, 400, 160, 240);
  const destination = Scaffold(body: Center(child: Text('Detail')));

  Widget app({bool reduceMotion = false}) => MaterialApp(
        navigatorKey: navigator,
        builder: (context, child) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: const Scaffold(body: Center(child: Text('Grove'))),
      );

  /// Pushes [route] and stops partway through the reveal.
  Future<void> pushHalfway(WidgetTester tester, Route<void> route) async {
    unawaited(navigator.currentState!.push(route));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

  Path clipNow(WidgetTester tester, Size size) {
    final clip = tester.widget<ClipPath>(find.byType(ClipPath));
    return clip.clipper!.getClip(size);
  }

  test('the reveal runs on tokens the app already had', () {
    final route = GGRevealRoute<void>.game(builder: (_) => destination);

    expect(route.transitionDuration, GGTokens.standard.durationNormal);
    expect(route.reverseTransitionDuration, GGTokens.standard.durationFast);
    // Returning is not news, so it is the brisker of the two.
    expect(route.reverseTransitionDuration, lessThan(route.transitionDuration));
  });

  testWidgets('a game opens out of the cover you tapped', (tester) async {
    await tester.pumpWidget(app());
    await pushHalfway(
      tester,
      GGRevealRoute<void>.game(origin: origin, builder: (_) => destination),
    );

    // Partway through, the page is present but not yet the whole screen.
    const screen = Size(800, 600);
    final mid = clipNow(tester, screen).getBounds();
    expect(mid.width, lessThan(screen.width));
    expect(mid.width, greaterThan(origin.width));

    await tester.pumpAndSettle();
    expect(find.text('Detail'), findsOneWidget);
    expect(clipNow(tester, screen).getBounds().width, screen.width);
  });

  testWidgets('a tap with no measurable box still opens', (tester) async {
    // Some callers hand over a context with no render box. That is a reason to
    // grow from the middle, not a reason to fail.
    await tester.pumpWidget(app());
    unawaited(
      navigator.currentState!.push(
        GGRevealRoute<void>.game(builder: (_) => destination),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detail'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a person opens through a different shape than a game',
      (tester) async {
    // The two are meant to be told apart: a cover leads you into a game, the
    // doorway leads you into someone's grove. If both resolved to one shape the
    // distinction would be decoration.
    const screen = Size(400, 800);

    await tester.pumpWidget(app());
    await pushHalfway(
      tester,
      GGRevealRoute<void>.grove(builder: (_) => destination),
    );
    final arch = clipNow(tester, screen).getBounds();

    await tester.pumpAndSettle();
    navigator.currentState!.pop();
    await tester.pumpAndSettle();

    await pushHalfway(
      tester,
      GGRevealRoute<void>.game(origin: origin, builder: (_) => destination),
    );
    final card = clipNow(tester, screen).getBounds();

    expect(arch, isNot(card));
    // A doorway stands taller than it is wide. A cover opening towards a
    // landscape screen does not.
    expect(arch.height, greaterThan(arch.width));
    expect(card.height, lessThan(card.width * 2));

    await tester.pumpAndSettle();
  });

  testWidgets('asked for less motion there is no reveal at all',
      (tester) async {
    await tester.pumpWidget(app(reduceMotion: true));
    await pushHalfway(
      tester,
      GGRevealRoute<void>.game(origin: origin, builder: (_) => destination),
    );

    // Not a faster reveal — none. Checked mid-flight, where a reveal would be
    // at its most visible. The same answer the portal loader gives.
    expect(find.byType(ClipPath), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('Detail'), findsOneWidget);
  });

  testWidgets('revealOriginOf reports the box a widget occupies',
      (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox(width: 160, height: 240);
              },
            ),
          ),
        ),
      ),
    );

    final measured = revealOriginOf(captured);
    expect(measured, isNotNull);
    expect(measured!.size, const Size(160, 240));
  });
}
