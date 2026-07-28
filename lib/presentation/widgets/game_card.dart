// presentation/widgets/game_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/navigation/gg_reveal_route.dart';
import 'package:gamer_grove/core/services/toast_service.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/user_states_section.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_badge_column.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_badges.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_caption.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_layers.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_user_states.dart';

export 'package:gamer_grove/presentation/widgets/game_card/card_user_states.dart';
export 'package:gamer_grove/presentation/widgets/game_card/game_card_shimmer.dart';

/// A game as a cover with everything the reader knows about it layered on top.
///
/// The pieces live in `game_card/`: the artwork and scrims, the badges, the
/// caption. This file is the composition and the one thing that needs a
/// `BuildContext` with blocs in it.
class GameCard extends StatelessWidget {
  const GameCard({
    required this.game,
    required this.onTap,
    super.key,
    this.blurRated = false,
    this.width,
    this.height,
    this.otherUserId,
    this.otherUserStates = CardUserStates.none,
  });

  final Game game;
  final VoidCallback onTap;

  /// Frosts the cover once the reader has rated the game.
  final bool blurRated;
  final double? width;
  final double? height;

  /// Set when the card is standing in someone else's grove; their states are
  /// then shown down the left edge alongside the reader's own on the right.
  final String? otherUserId;
  final CardUserStates otherUserStates;

  @override
  Widget build(BuildContext context) {
    // Expose the whole card as a single tappable button node so screen
    // readers announce the game (title, rating, genres) once instead of
    // walking every decorative overlay.
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: GestureDetector(
          onTap: () async {
            // Measured here, from the card's own context, because the caller
            // usually hands the navigation helper a sliver's context instead.
            RevealOrigin.record(context);
            await HapticFeedback.lightImpact();
            onTap.call();
          },
          onLongPress: () async {
            await HapticFeedback.vibrate();
            if (context.mounted) await _showUserStatesSheet(context);
          },
          child: _frame(context),
        ),
      ),
    );
  }

  Widget _frame(BuildContext context) {
    final radius = BorderRadius.circular(context.ggTokens.radiusLg);

    return Container(
      width: width ?? 160,
      height: height ?? 240,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BlocBuilder<UserGameDataBloc, UserGameDataState>(
          buildWhen: _thisGameChanged,
          builder: (context, state) => _layers(context, _statesFrom(state)),
        ),
      ),
    );
  }

  /// The bloc holds every game's states, so most of its updates say nothing
  /// about this card.
  bool _thisGameChanged(UserGameDataState previous, UserGameDataState current) {
    if (previous.runtimeType != current.runtimeType) return true;
    if (previous is! UserGameDataLoaded || current is! UserGameDataLoaded) {
      return true;
    }
    return _statesFrom(previous) != _statesFrom(current);
  }

  CardUserStates _statesFrom(UserGameDataState state) {
    if (state is! UserGameDataLoaded) return CardUserStates.none;
    return CardUserStates(
      rating: state.getRating(game.id),
      isWishlisted: state.isWishlisted(game.id),
      isRecommended: state.isRecommended(game.id),
      topThreePosition: state.isInTopThree(game.id)
          ? state.getTopThreePosition(game.id)
          : null,
    );
  }

  Widget _layers(BuildContext context, CardUserStates states) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CardArtwork(coverUrl: game.coverUrl),
        if (blurRated && states.rating != null) const CardBlur(),
        const CardCaptionScrim(),
        if (states.isNotEmpty)
          CardBadgeScrim(states: states, alignment: Alignment.centerRight),
        if (otherUserStates.isNotEmpty)
          CardBadgeScrim(
            states: otherUserStates,
            alignment: Alignment.centerLeft,
          ),
        CardCaption(game: game),
        if (otherUserId != null)
          CardBadgeColumn(
            states: otherUserStates,
            alignment: Alignment.centerLeft,
          ),
        CardBadgeColumn(states: states, alignment: Alignment.centerRight),
        if (game.totalRating != null)
          Positioned(
            bottom: 6,
            right: 6,
            child: RatingBadge.igdb(game.totalRating!),
          ),
      ],
    );
  }

  Future<void> _showUserStatesSheet(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      GamerGroveToastService.showWarning(
        context,
        title: 'Login Required',
        message: 'Please log in to manage your game states.',
      );
      return;
    }

    final bloc = BlocProvider.of<UserGameDataBloc>(context);
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  game.name,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                UserStatesContent(game: game),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
