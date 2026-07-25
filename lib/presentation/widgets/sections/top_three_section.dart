import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/top_three/top_three_stack.dart';

/// The Top 3 as the stage of the Grove, rather than one card among five.
///
/// This deliberately no longer extends `BaseGameSection`: that base wraps every
/// section in the same `SectionFrame` card, which is what flattened the home
/// screen — the app's signature statement carrying the same weight as the
/// wishlist. Here the section owns its layout.
class TopThreeSection extends StatelessWidget {
  const TopThreeSection({
    super.key,
    this.currentUserId,
    this.gameBloc,
    this.username,
  });

  final String? currentUserId;
  final GameBloc? gameBloc;

  /// Set when viewing somebody else's grove.
  final String? username;

  bool get _isOwn => username == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.ggTokens;

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final games = switch (state) {
          GrovePageLoaded(:final userTopThree) => userTopThree,
          _ => const <Game>[],
        };
        final isLoading = state is GrovePageLoading;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.spaceMd,
            tokens.spaceSm,
            tokens.spaceMd,
            tokens.spaceLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isOwn ? 'YOUR TOP 3' : "${username!.toUpperCase()}'S TOP 3",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.6,
                ),
              ),
              SizedBox(height: tokens.spaceXs),
              Text(
                _isOwn
                    ? 'The best you have played'
                    : 'What $username likes most',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: tokens.spaceMd),
              if (isLoading)
                const _StackFootprint()
              else
                TopThreeStack(
                  games: games.take(TopThreeStack.slots).toList(),
                  onOpenGame: (game) =>
                      Navigations.navigateToGameDetail(game.id, context),
                ),
              if (!isLoading && _isOwn && games.length < TopThreeStack.slots)
                Padding(
                  padding: EdgeInsets.only(top: tokens.spaceMd),
                  child: Text(
                    // There is no picker to send people to yet: the Top 3 is
                    // set from a game's page. Say where, rather than offering a
                    // tap that goes nowhere.
                    'Fill the empty places with the star on a game page.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Holds the stack's footprint while it loads, so the headline above does not
/// jump once the covers arrive.
class _StackFootprint extends StatelessWidget {
  const _StackFootprint();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: constraints.maxWidth * 0.46 * 4 / 3 + context.ggTokens.spaceXl,
      ),
    );
  }
}
