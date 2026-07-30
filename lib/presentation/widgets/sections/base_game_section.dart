// lib/presentation/widgets/base_game_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/theme/gg_chamber_light.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import 'package:gamer_grove/presentation/widgets/loading/dither_skeleton.dart';
import 'package:gamer_grove/presentation/widgets/sections/chamber_tint.dart';
import 'package:gamer_grove/presentation/widgets/sections/lit_section.dart';

abstract class BaseGameSection extends StatelessWidget {
  const BaseGameSection({
    super.key,
    this.currentUserId,
    this.gameBloc,
  });
  final String? currentUserId;
  final GameBloc? gameBloc;

  // Abstract methods - must be implemented by subclasses
  String get title;
  String get subtitle;
  IconData get icon;
  bool get showViewAll => true;

  /// The games this section is showing, so its light can be taken from their
  /// covers. Defaults to none, which keeps the brand accent — a section only
  /// gets its own colour once it can say which games it is made of.
  List<Game> gamesOf(GameState state) => const [];

  /// How this section is lit. `steady` is the honest default: light in this app
  /// means something, so a section only claims a mode when its content
  /// actually carries that meaning. Lighting the first entry of a wishlist
  /// would assert an importance that the position does not have.
  ChamberLightMode get lightMode => ChamberLightMode.steady;

  // Abstract method for navigation
  void onViewAllPressed(BuildContext context);

  // Abstract method for specific state handling
  Widget buildSectionContent(BuildContext context, GameState state);

  // Abstract method for retry action
  void onRetryAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return buildGameSection(
          context: context,
          title: title,
          subtitle: subtitle,
          icon: icon,
          showViewAll: showViewAll,
          onViewAll: showViewAll ? () => onViewAllPressed(context) : null,
          coverUrls: [for (final game in gamesOf(state)) game.coverUrl],
          child: buildSectionContent(context, state),
        );
      },
    );
  }

  // Shared UI building methods
  Widget buildGameSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    List<String?> coverUrls = const [],
    bool showViewAll = false,
    VoidCallback? onViewAll,
  }) {
    // The card frame is gone: five identical boxes gave every section the same
    // weight. Hierarchy now comes from light — see LitSection. `subtitle` and
    // `icon` stay in the signature because the subclasses still declare them,
    // but the design no longer shows either; both were filler that repeated
    // the title ("Rated Games" / "Games you rated").
    // The chamber's light is taken from the covers standing in it, so two
    // people's Groves do not look alike. Falls back to the brand accent while
    // the covers are still loading, or when they have no usable hue.
    return ChamberTint(
      coverUrls: coverUrls,
      builder: (context, tint) => LitSection(
        title: title,
        lightMode: lightMode,
        tint: tint,
        onViewAll: showViewAll ? onViewAll : null,
        child: child,
      ),
    );
  }

  Widget buildHorizontalGameList(List<Game> games) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];

          // Get logged-in user ID
          final authState = context.read<AuthBloc>().state;
          final loggedInUserId =
              authState is AuthAuthenticated ? authState.user.id : null;

          // Only show other user states if viewing a different user's profile
          final isDifferentUser =
              currentUserId != null && currentUserId != loggedInUserId;

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: GameCard(
              game: game,
              onTap: () => Navigations.navigateToGameDetail(game.id, context,
                  known: game),
              // Pass other user's states only if viewing different user
              otherUserId: isDifferentUser ? currentUserId : null,
              otherUserStates: isDifferentUser
                  ? CardUserStates.fromGame(game)
                  : CardUserStates.none,
            ),
          );
        },
      ),
    );
  }

  /// One shared skeleton in the shape of the rail it stands in for, so the
  /// layout does not jump when the covers arrive. The old one hand-rolled a
  /// card with a grey shimmer per section.
  Widget buildHorizontalGameListSkeleton() => const DitherRailSkeleton(
        coverWidth: 160,
        count: 5,
      );

  Widget buildEmptySection(
    String message,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildErrorSection(String message, BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 32,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onRetryAction,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(80, 32),
                  textStyle: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
