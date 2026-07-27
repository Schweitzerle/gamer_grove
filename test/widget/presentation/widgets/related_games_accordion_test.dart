import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_color_schemes.dart';
import 'package:gamer_grove/core/theme/gg_contrast.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/content_dlc_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/related_games_accordion.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/related_games_tab.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/similar_related_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/versions_remakes_section.dart';

class _MockUserGameDataBloc
    extends MockBloc<UserGameDataEvent, UserGameDataState>
    implements UserGameDataBloc {}

void main() {
  // Covers carry no URL, so an expanded tab renders the local fallback and the
  // tests never reach for the network.
  const dlc = Game(id: 2, name: 'The Frozen Wilds');
  const bundle = Game(id: 3, name: 'Complete Edition');

  late _MockUserGameDataBloc userGameData;

  setUp(() {
    userGameData = _MockUserGameDataBloc();
    whenListen(
      userGameData,
      const Stream<UserGameDataState>.empty(),
      initialState: const UserGameDataInitial(),
    );
  });

  Widget wrap(Widget child) => MaterialApp(
        theme: GGTheme.dark(),
        home: BlocProvider<UserGameDataBloc>.value(
          value: userGameData,
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );

  group('an accordion with nothing in it takes no room', () {
    testWidgets('the accordion itself collapses to nothing', (tester) async {
      await tester.pumpWidget(
        wrap(
          const RelatedGamesAccordion(
            title: 'Additional Content',
            icon: Icons.extension,
            accent: Colors.green,
            gameName: 'Horizon',
            tabs: [],
          ),
        ),
      );

      expect(find.text('Additional Content'), findsNothing);
      expect(tester.getSize(find.byType(RelatedGamesAccordion)), Size.zero);
    });
  });

  testWidgets('collapsed, it says what it holds and how much', (tester) async {
    await tester.pumpWidget(
      wrap(
        const ContentDLCSection(
          game: Game(
            id: 1,
            name: 'Horizon',
            dlcs: [dlc],
            bundles: [bundle, bundle],
          ),
        ),
      ),
    );

    expect(find.text('Additional Content'), findsOneWidget);
    expect(find.text('⬇️ DLCs • 📋 Bundles'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    // Closed means not built: `AnimatedAlign` only clips, so until the first
    // tap the covers must not exist at all.
    expect(find.text('The Frozen Wilds'), findsNothing);
    expect(find.byType(TabBarView), findsNothing);
  });

  testWidgets('tapping the header opens it', (tester) async {
    await tester.pumpWidget(
      wrap(
        const ContentDLCSection(
          game: Game(id: 1, name: 'Horizon', dlcs: [dlc]),
        ),
      ),
    );

    await tester.tap(find.text('Additional Content'));
    await tester.pumpAndSettle();

    expect(find.text('Downloadable Content'), findsOneWidget);
    expect(find.text('Additional content • 1 DLCs'), findsOneWidget);
  });

  testWidgets('the header announces whether it is open', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        const ContentDLCSection(
          game: Game(id: 1, name: 'Horizon', dlcs: [dlc]),
        ),
      ),
    );

    final header = find.ancestor(
      of: find.text('Additional Content'),
      matching: find.byType(Semantics),
    );
    expect(
      tester.getSemantics(header.first),
      isSemantics(
        isButton: true,
        hasExpandedState: true,
        isExpanded: false,
        hasTapAction: true,
      ),
    );

    handle.dispose();
  });

  group('every accent reads on both surfaces', () {
    // The reason this exists: `Colors.green` is 2.60:1 on the light surface and
    // `Colors.purple` is 2.92:1 on the dark one. Each section used its accent
    // directly as small text, so half of these labels failed AA — and on only
    // one theme, which is why nobody saw it.
    // A game carrying one of everything, so every tab the three sections can
    // produce is present exactly once.
    final everyTab = <RelatedGamesTab>[
      ...const ContentDLCSection(
        game: Game(
          id: 1,
          name: 'Horizon',
          dlcs: [dlc],
          expansions: [dlc],
          standaloneExpansions: [dlc],
          bundles: [dlc],
        ),
      ).tabs,
      ...const VersionsRemakesSection(
        game: Game(
          id: 1,
          name: 'Horizon',
          remakes: [dlc],
          remasters: [dlc],
          ports: [dlc],
          expandedGames: [dlc],
          versionParent: dlc,
        ),
      ).tabs,
      ...const SimilarRelatedSection(
        game: Game(
          id: 1,
          name: 'Horizon',
          similarGames: [dlc],
          forks: [dlc],
          parentGame: dlc,
        ),
      ).tabs,
    ];

    test('all twelve tabs are covered', () {
      expect(everyTab, hasLength(12));
    });

    for (final scheme in [GGColorSchemes.dark, GGColorSchemes.light]) {
      final name = scheme == GGColorSchemes.dark ? 'dark' : 'light';

      test('on the $name surface', () {
        for (final tab in everyTab) {
          final shown = tab.accent.legibleOn(scheme.surface, minimum: 4.5);
          expect(
            scheme.surface.contrastAgainst(shown),
            greaterThanOrEqualTo(4.5),
            reason: '${tab.label} is unreadable on the $name surface',
          );
        }
      });
    }
  });
}
