import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/entities/statistics/game_statistics.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/statistics/statistics_bloc.dart';
import 'package:gamer_grove/presentation/widgets/statistics/stat_item.dart';
import 'package:gamer_grove/presentation/widgets/statistics/statistics_card.dart';

/// Page displaying user's gaming statistics
class ProfileStatisticsPage extends StatelessWidget {
  /// Creates a ProfileStatisticsPage
  const ProfileStatisticsPage({
    required this.userId,
    super.key,
  });

  /// User ID to display statistics for
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<StatisticsBloc>()..add(LoadStatisticsEvent(userId: userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gaming Statistics'),
        ),
        body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is StatisticsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<StatisticsBloc>()
                            .add(LoadStatisticsEvent(userId: userId));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is StatisticsEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No statistics yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rate some games to see your statistics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              );
            }

            if (state is StatisticsLoaded) {
              return _buildStatistics(context, state.statistics);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, GameStatistics stats) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Overview
        _buildOverviewCard(context, stats),

        // Genres
        if (stats.genreStats.topGenres.isNotEmpty)
          _buildGenresCard(context, stats.genreStats),

        // Platforms
        if (stats.platformStats.topPlatforms.isNotEmpty)
          _buildPlatformsCard(context, stats.platformStats),

        // Themes
        if (stats.themeStats.topThemes.isNotEmpty)
          _buildThemesCard(context, stats.themeStats),

        // Game Modes
        if (stats.gameModeStats.topModes.isNotEmpty)
          _buildGameModesCard(context, stats.gameModeStats),

        // Ratings
        _buildRatingsCard(context, stats.ratingStats),

        // Developers
        if (stats.developerStats.topDevelopers.isNotEmpty)
          _buildDevelopersCard(context, stats.developerStats),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context, GameStatistics stats) {
    return StatisticsCard(
      title: 'Overview',
      icon: Icons.analytics_rounded,
      child: Column(
        children: [
          StatItem(
            label: 'Total Rated Games',
            value: stats.totalGames.toString(),
          ),
          StatItem(
            label: 'Average Rating',
            value: stats.ratingStats.averageRating.toStringAsFixed(1),
          ),
          StatItem(
            label: 'Unique Genres',
            value: stats.genreStats.distribution.length.toString(),
          ),
          StatItem(
            label: 'Unique Platforms',
            value: stats.platformStats.distribution.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresCard(BuildContext context, GenreStats stats) {
    return StatisticsCard(
      title: 'Top Genres',
      icon: Icons.category_rounded,
      collapsible: true,
      child: Column(
        children: stats.topGenres
            .map(
              (genre) => StatItem(
                label: genre.name,
                value: genre.count.toString(),
                percentage: genre.percentage,
                showProgress: true,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPlatformsCard(BuildContext context, PlatformStats stats) {
    return StatisticsCard(
      title: 'Top Platforms',
      icon: Icons.videogame_asset_rounded,
      collapsible: true,
      child: Column(
        children: stats.topPlatforms
            .map(
              (platform) => StatItem(
                label: platform.abbreviation ?? platform.name,
                value: platform.count.toString(),
                percentage: platform.percentage,
                showProgress: true,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildThemesCard(BuildContext context, ThemeStats stats) {
    return StatisticsCard(
      title: 'Top Themes',
      icon: Icons.palette_rounded,
      collapsible: true,
      child: Column(
        children: stats.topThemes
            .map(
              (theme) => StatItem(
                label: theme.name,
                value: theme.count.toString(),
                percentage: theme.percentage,
                showProgress: true,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildGameModesCard(BuildContext context, GameModeStats stats) {
    return StatisticsCard(
      title: 'Game Modes',
      icon: Icons.sports_esports_rounded,
      collapsible: true,
      child: Column(
        children: stats.topModes
            .map(
              (mode) => StatItem(
                label: mode.name,
                value: mode.count.toString(),
                percentage: mode.percentage,
                showProgress: true,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRatingsCard(BuildContext context, RatingStats stats) {
    return StatisticsCard(
      title: 'Rating Distribution',
      icon: Icons.star_rounded,
      collapsible: true,
      child: Column(
        children: [
          StatItem(
            label: 'Average Rating',
            value: stats.averageRating.toStringAsFixed(1),
          ),
          StatItem(
            label: 'Highest Rating',
            value: stats.highestRating.toStringAsFixed(1),
          ),
          StatItem(
            label: 'Lowest Rating',
            value: stats.lowestRating.toStringAsFixed(1),
          ),
          const SizedBox(height: 16),
          StatItem(
            label: 'Games Rated 5+ Stars',
            value: stats.gamesRated5OrMore.toString(),
            percentage: stats.totalRatings > 0
                ? (stats.gamesRated5OrMore / stats.totalRatings) * 100
                : 0,
            showProgress: true,
          ),
          StatItem(
            label: 'Games Rated Below 5 Stars',
            value: stats.gamesRatedBelow5.toString(),
            percentage: stats.totalRatings > 0
                ? (stats.gamesRatedBelow5 / stats.totalRatings) * 100
                : 0,
            showProgress: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopersCard(BuildContext context, DeveloperStats stats) {
    return StatisticsCard(
      title: 'Top Developers',
      icon: Icons.code_rounded,
      collapsible: true,
      child: Column(
        children: [
          if (stats.topDevelopers.isNotEmpty) ...[
            Text(
              'Developers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...stats.topDevelopers.take(5).map(
                  (dev) => StatItem(
                    label: dev.name,
                    value: dev.count.toString(),
                    percentage: dev.percentage,
                    showProgress: true,
                  ),
                ),
            const SizedBox(height: 16),
          ],
          if (stats.topPublishers.isNotEmpty) ...[
            Text(
              'Publishers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...stats.topPublishers.take(5).map(
                  (pub) => StatItem(
                    label: pub.name,
                    value: pub.count.toString(),
                    percentage: pub.percentage,
                    showProgress: true,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
