// lib/presentation/widgets/base_game_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/presentation/pages/game_detail/game_detail_page.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/game.dart';
import '../../blocs/game/game_bloc.dart';
import '../custom_shimmer.dart';
import '../game_card.dart';

abstract class BaseGameSection extends StatelessWidget {
  final String? currentUserId;
  final GameBloc? gameBloc;

  const BaseGameSection({
    super.key,
    this.currentUserId,
    this.gameBloc,
  });

  // Abstract methods - must be implemented by subclasses
  String get title;
  String get subtitle;
  IconData get icon;
  bool get showViewAll => true;

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
    bool showViewAll = false,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showViewAll && onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Section Content
          child,
        ],
      ),
    );
  }

  Widget buildHorizontalGameList(List<Game> games) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: GameCard(
              game: game,
              onTap: () => Navigations.navigateToGameDetail(game.id, context)
            ),
          );
        },
      ),
    );
  }

  Widget buildHorizontalGameListSkeleton() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomShimmer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppConstants.borderRadius),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomShimmer(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomShimmer(
                            child: Container(
                              height: 12,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildEmptySection(String message, IconData icon, BuildContext context) {
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