import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/widgets/loading/live_loading_progress.dart';
import 'package:gamer_grove/presentation/widgets/loading/loading_step.dart';

void main() {
  const steps = [
    LoadingStep(text: 'Verbinde mit IGDB', substep: 'Sitzung wird geöffnet'),
    LoadingStep(text: 'Lade Spieldaten'),
    LoadingStep(text: 'Bereite Ansicht vor'),
  ];

  Future<void> pump(WidgetTester tester, {bool reduceMotion = true}) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          theme: GGTheme.dark(),
          home: const Scaffold(
            body: LiveLoadingProgress(
              title: 'Spiel wird geladen',
              steps: steps,
              stepDuration: Duration(milliseconds: 300),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('starts on the first step and reveals the ones already passed',
      (tester) async {
    await pump(tester);

    expect(find.text('Verbinde mit IGDB'), findsOneWidget);
    // Upcoming steps stay hidden: a readout that lists everything up front is
    // a table of contents, not progress.
    expect(find.text('Lade Spieldaten'), findsNothing);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Verbinde mit IGDB'), findsOneWidget);
    expect(find.text('Lade Spieldaten'), findsOneWidget);
  });

  testWidgets('the substep only shows for the step in progress',
      (tester) async {
    await pump(tester);
    expect(find.text('Sitzung wird geöffnet'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Sitzung wird geöffnet'), findsNothing);
  });

  testWidgets('holds on the last step instead of wrapping or claiming success',
      (tester) async {
    await pump(tester);

    // Far longer than the whole sequence takes.
    await tester.pump(const Duration(seconds: 5));

    expect(find.text('Bereite Ansicht vor'), findsOneWidget);
    // The timer knows nothing about whether the data arrived, so it must not
    // report a finish.
    expect(find.text('Fertig'), findsNothing);
    expect(find.text('Verbinde mit IGDB'), findsOneWidget);
  });

  testWidgets('announces the current step to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    expect(
      find.bySemanticsLabel('Spiel wird geladen. Verbinde mit IGDB'),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });

  testWidgets('runs without a ticker when motion is reduced', (tester) async {
    await pump(tester);
    // No pending animation means pumpAndSettle terminates; with a repeating
    // controller alive it would time out.
    await tester.pumpAndSettle();
    expect(find.byType(LiveLoadingProgress), findsOneWidget);
  });
}
