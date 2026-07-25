import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/top_three/top_three_stack.dart';

/// Covers are deliberately given no `coverUrl`: the widget then paints its own
/// placeholder instead of reaching for the network, so these tests stay
/// deterministic and offline.
Game _game(int id, String name) => Game(id: id, name: name, totalRating: 94);

void main() {
  final games = [
    _game(1, 'Hollow Knight: Silksong'),
    _game(2, 'Outer Wilds'),
    _game(3, 'Return of the Obra Dinn'),
  ];

  Future<List<Game>> pump(
    WidgetTester tester, {
    List<Game>? entries,
    bool reduceMotion = true,
    VoidCallback? onFillSlot,
  }) async {
    final opened = <Game>[];
    await tester.pumpWidget(
      MediaQuery(
        // Motion off by default: the intro cycle is timer-driven, and a test
        // that lets it run is a test that races it.
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MaterialApp(
          theme: GGTheme.dark(),
          home: Scaffold(
            body: TopThreeStack(
              games: entries ?? games,
              onOpenGame: opened.add,
              onFillSlot: onFillSlot,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return opened;
  }

  Finder slot(int rank, {required bool front}) => find.bySemanticsLabel(
        RegExp(
          front
              ? 'Place $rank:.*Tap to open'
              : 'Place $rank:.*bring it to the front',
        ),
      );

  testWidgets('shows all three ranks, with rank one in front', (tester) async {
    await pump(tester);

    expect(slot(1, front: true), findsOneWidget);
    expect(slot(2, front: false), findsOneWidget);
    expect(slot(3, front: false), findsOneWidget);
  });

  testWidgets('the front cover opens its game', (tester) async {
    final opened = await pump(tester);

    await tester.tap(slot(1, front: true));
    await tester.pumpAndSettle();

    expect(opened.single.name, 'Hollow Knight: Silksong');
  });

  testWidgets('a cover behind is brought forward instead of opened',
      (tester) async {
    final opened = await pump(tester);

    await tester.tap(slot(2, front: false));
    await tester.pumpAndSettle();

    // The whole point of the rule: a half-hidden, darkened cover is a poor tap
    // target, so the first tap only fetches it into the light.
    expect(opened, isEmpty);
    expect(slot(2, front: true), findsOneWidget);
    expect(slot(1, front: false), findsOneWidget);

    await tester.tap(slot(2, front: true));
    await tester.pumpAndSettle();
    expect(opened.single.name, 'Outer Wilds');
  });

  testWidgets('swiping brings the next cover forward', (tester) async {
    await pump(tester);

    await tester.fling(
      find.byType(TopThreeStack),
      const Offset(-200, 0),
      800,
    );
    await tester.pumpAndSettle();

    expect(slot(2, front: true), findsOneWidget);
  });

  testWidgets('unfilled places are inert when there is nowhere to send anyone',
      (tester) async {
    await pump(tester, entries: [games.first]);

    expect(find.bySemanticsLabel('Place 2 is still empty'), findsOneWidget);
    expect(find.bySemanticsLabel('Place 3 is still empty'), findsOneWidget);
    // Inert, so it must not announce itself as a button.
    final node = tester.getSemantics(
      find.bySemanticsLabel('Place 2 is still empty'),
    );
    expect(node.flagsCollection.isButton, isFalse);
  });

  testWidgets('unfilled places become buttons once they lead somewhere',
      (tester) async {
    var taps = 0;
    await pump(tester, entries: [games.first], onFillSlot: () => taps++);

    await tester.tap(
      find.bySemanticsLabel(RegExp('Place 2 is still empty. Tap')),
    );
    expect(taps, 1);
  });

  testWidgets('reduced motion leaves the stack resting on rank one',
      (tester) async {
    await pump(tester);
    // Long enough that the intro cycle would have run several steps.
    await tester.pump(const Duration(seconds: 9));

    expect(slot(1, front: true), findsOneWidget);
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });
}
