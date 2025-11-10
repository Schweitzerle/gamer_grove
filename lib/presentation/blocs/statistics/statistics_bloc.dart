import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/statistics/game_statistics.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

/// BLoC for handling game statistics operations
///
/// This BLoC loads the user's rated games and calculates various statistics
/// such as genre distribution, platform usage, theme preferences, etc.
///
/// Example:
/// ```dart
/// // Load statistics
/// context.read<StatisticsBloc>().add(
///   LoadStatisticsEvent(userId: userId),
/// );
///
/// // Refresh statistics
/// context.read<StatisticsBloc>().add(
///   RefreshStatisticsEvent(userId: userId),
/// );
/// ```
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {

  /// Creates a StatisticsBloc
  StatisticsBloc({
    required this.gameRepository,
  }) : super(const StatisticsInitial()) {
    on<LoadStatisticsEvent>(_onLoadStatistics);
    on<RefreshStatisticsEvent>(_onRefreshStatistics);
  }
  /// Game repository for fetching user's rated games
  final GameRepository gameRepository;

  /// Handles loading statistics
  Future<void> _onLoadStatistics(
    LoadStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());
    await _loadAndCalculateStatistics(event.userId, emit);
  }

  /// Handles refreshing statistics
  Future<void> _onRefreshStatistics(
    RefreshStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    // Keep current state while refreshing, or show loading if no data
    if (state is! StatisticsLoaded) {
      emit(const StatisticsLoading());
    }
    await _loadAndCalculateStatistics(event.userId, emit);
  }

  /// Loads rated games and calculates statistics
  Future<void> _loadAndCalculateStatistics(
    String userId,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      // Fetch all rated games for the user
      // We'll fetch in batches if needed
      final allGames = <Game>[];
      const batchSize = 100;
      var offset = 0;
      var hasMore = true;

      while (hasMore) {
        final result = await gameRepository.getUserRated(
          userId,
          batchSize,
          offset,
        );

        result.fold(
          (failure) => throw Exception(failure.message),
          (games) {
            allGames.addAll(games);
            hasMore = games.length == batchSize;
            offset += batchSize;
          },
        );
      }

      // Check if user has any rated games
      if (allGames.isEmpty) {
        emit(StatisticsEmpty(userId: userId));
        return;
      }

      // Calculate statistics from the games
      final statistics = _calculateStatistics(allGames);

      emit(StatisticsLoaded(
        statistics: statistics,
        userId: userId,
      ),);
    } catch (e) {
      emit(StatisticsError('Failed to load statistics: $e'));
    }
  }

  /// Calculates statistics from a list of games
  GameStatistics _calculateStatistics(List<Game> games) {
    return GameStatistics(
      genreStats: _calculateGenreStats(games),
      platformStats: _calculatePlatformStats(games),
      themeStats: _calculateThemeStats(games),
      gameModeStats: _calculateGameModeStats(games),
      ratingStats: _calculateRatingStats(games),
      developerStats: _calculateDeveloperStats(games),
      totalGames: games.length,
    );
  }

  /// Calculates genre statistics
  GenreStats _calculateGenreStats(List<Game> games) {
    final distribution = <String, int>{};

    for (final game in games) {
      for (final genre in game.genres) {
        distribution[genre.name] = (distribution[genre.name] ?? 0) + 1;
      }
        }

    // Calculate percentages and sort
    final totalGames = games.length;
    final topGenres = distribution.entries
        .map((e) => GenreData(
              name: e.key,
              count: e.value,
              percentage: (e.value / totalGames) * 100,
            ),)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return GenreStats(
      distribution: distribution,
      topGenres: topGenres.take(10).toList(),
    );
  }

  /// Calculates platform statistics
  PlatformStats _calculatePlatformStats(List<Game> games) {
    final distribution = <String, int>{};
    final abbreviations = <String, String?>{};

    for (final game in games) {
      for (final platform in game.platforms) {
        distribution[platform.name] =
            (distribution[platform.name] ?? 0) + 1;
        abbreviations[platform.name] = platform.abbreviation;
      }
        }

    // Calculate percentages and sort
    final totalGames = games.length;
    final topPlatforms = distribution.entries
        .map((e) => PlatformData(
              name: e.key,
              count: e.value,
              percentage: (e.value / totalGames) * 100,
              abbreviation: abbreviations[e.key],
            ),)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return PlatformStats(
      distribution: distribution,
      topPlatforms: topPlatforms.take(10).toList(),
    );
  }

  /// Calculates theme statistics
  ThemeStats _calculateThemeStats(List<Game> games) {
    final distribution = <String, int>{};

    for (final game in games) {
      for (final theme in game.themes) {
        distribution[theme.name] = (distribution[theme.name] ?? 0) + 1;
      }
        }

    // Calculate percentages and sort
    final totalGames = games.length;
    final topThemes = distribution.entries
        .map((e) => ThemeData(
              name: e.key,
              count: e.value,
              percentage: (e.value / totalGames) * 100,
            ),)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return ThemeStats(
      distribution: distribution,
      topThemes: topThemes.take(10).toList(),
    );
  }

  /// Calculates game mode statistics
  GameModeStats _calculateGameModeStats(List<Game> games) {
    final distribution = <String, int>{};

    for (final game in games) {
      for (final mode in game.gameModes) {
        distribution[mode.name] = (distribution[mode.name] ?? 0) + 1;
      }
        }

    // Calculate percentages and sort
    final totalGames = games.length;
    final topModes = distribution.entries
        .map((e) => GameModeData(
              name: e.key,
              count: e.value,
              percentage: (e.value / totalGames) * 100,
            ),)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return GameModeStats(
      distribution: distribution,
      topModes: topModes.take(10).toList(),
    );
  }

  /// Calculates rating statistics
  RatingStats _calculateRatingStats(List<Game> games) {
    final ratings = games
        .where((game) => game.userRating != null)
        .map((game) => game.userRating!)
        .toList();

    if (ratings.isEmpty) {
      return const RatingStats(
        averageRating: 0,
        ratingDistribution: {},
        totalRatings: 0,
        highestRating: 0,
        lowestRating: 0,
        gamesRated5OrMore: 0,
        gamesRatedBelow5: 0,
      );
    }

    // Calculate distribution (rounded to nearest integer)
    final distribution = <int, int>{};
    var gamesRated5OrMore = 0;
    var gamesRatedBelow5 = 0;

    for (final rating in ratings) {
      final rounded = rating.round();
      distribution[rounded] = (distribution[rounded] ?? 0) + 1;

      if (rating >= 5.0) {
        gamesRated5OrMore++;
      } else {
        gamesRatedBelow5++;
      }
    }

    final averageRating =
        ratings.reduce((a, b) => a + b) / ratings.length;

    return RatingStats(
      averageRating: averageRating,
      ratingDistribution: distribution,
      totalRatings: ratings.length,
      highestRating: ratings.reduce((a, b) => a > b ? a : b),
      lowestRating: ratings.reduce((a, b) => a < b ? a : b),
      gamesRated5OrMore: gamesRated5OrMore,
      gamesRatedBelow5: gamesRatedBelow5,
    );
  }

  /// Calculates developer/publisher statistics
  DeveloperStats _calculateDeveloperStats(List<Game> games) {
    final developers = <String, int>{};
    final publishers = <String, int>{};
    final allCompanies = <String, int>{};

    for (final game in games) {
      for (final involved in game.involvedCompanies) {
        final companyName = involved.company.name;
        allCompanies[companyName] = (allCompanies[companyName] ?? 0) + 1;

        if (involved.isDeveloper) {
          developers[companyName] = (developers[companyName] ?? 0) + 1;
        }
        if (involved.isPublisher) {
          publishers[companyName] = (publishers[companyName] ?? 0) + 1;
        }
      }
    }

    final totalGames = games.length;

    // Calculate top developers
    final topDevelopers = developers.entries
        .map((e) => DeveloperData(
              name: e.key,
              count: e.value,
              percentage: (e.value / totalGames) * 100,
            ),)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    // Calculate top publishers
    final topPublishers = publishers.entries
        .map((e) => DeveloperData(
              name: e.key,
              count: e.value,
              percentage: (e.value / totalGames) * 100,
            ),)
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return DeveloperStats(
      distribution: allCompanies,
      topDevelopers: topDevelopers.take(10).toList(),
      topPublishers: topPublishers.take(10).toList(),
    );
  }
}
