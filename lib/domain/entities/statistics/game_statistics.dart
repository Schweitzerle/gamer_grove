import 'package:equatable/equatable.dart';

/// Statistics entity containing user's gaming statistics
class GameStatistics extends Equatable {

  /// Creates a GameStatistics instance
  const GameStatistics({
    required this.genreStats,
    required this.platformStats,
    required this.themeStats,
    required this.gameModeStats,
    required this.ratingStats,
    required this.developerStats,
    required this.totalGames,
  });
  /// Genre statistics
  final GenreStats genreStats;

  /// Platform statistics
  final PlatformStats platformStats;

  /// Theme statistics
  final ThemeStats themeStats;

  /// Game mode statistics
  final GameModeStats gameModeStats;

  /// Rating statistics
  final RatingStats ratingStats;

  /// Developer/Publisher statistics
  final DeveloperStats developerStats;

  /// Total number of games analyzed
  final int totalGames;

  @override
  List<Object?> get props => [
        genreStats,
        platformStats,
        themeStats,
        gameModeStats,
        ratingStats,
        developerStats,
        totalGames,
      ];
}

/// Genre statistics
class GenreStats extends Equatable {

  /// Creates a GenreStats instance
  const GenreStats({
    required this.distribution,
    required this.topGenres,
  });
  /// Distribution of genres (genre name -> count)
  final Map<String, int> distribution;

  /// Top genres sorted by count
  final List<GenreData> topGenres;

  @override
  List<Object?> get props => [distribution, topGenres];
}

/// Genre data entry
class GenreData extends Equatable {

  /// Creates a GenreData instance
  const GenreData({
    required this.name,
    required this.count,
    required this.percentage,
  });
  /// Genre name
  final String name;

  /// Number of games with this genre
  final int count;

  /// Percentage of total games
  final double percentage;

  @override
  List<Object?> get props => [name, count, percentage];
}

/// Platform statistics
class PlatformStats extends Equatable {

  /// Creates a PlatformStats instance
  const PlatformStats({
    required this.distribution,
    required this.topPlatforms,
  });
  /// Distribution of platforms (platform name -> count)
  final Map<String, int> distribution;

  /// Top platforms sorted by count
  final List<PlatformData> topPlatforms;

  @override
  List<Object?> get props => [distribution, topPlatforms];
}

/// Platform data entry
class PlatformData extends Equatable {

  /// Creates a PlatformData instance
  const PlatformData({
    required this.name,
    required this.count,
    required this.percentage,
    this.abbreviation,
  });
  /// Platform name
  final String name;

  /// Number of games on this platform
  final int count;

  /// Percentage of total games
  final double percentage;

  /// Platform abbreviation
  final String? abbreviation;

  @override
  List<Object?> get props => [name, count, percentage, abbreviation];
}

/// Theme statistics
class ThemeStats extends Equatable {

  /// Creates a ThemeStats instance
  const ThemeStats({
    required this.distribution,
    required this.topThemes,
  });
  /// Distribution of themes (theme name -> count)
  final Map<String, int> distribution;

  /// Top themes sorted by count
  final List<ThemeData> topThemes;

  @override
  List<Object?> get props => [distribution, topThemes];
}

/// Theme data entry
class ThemeData extends Equatable {

  /// Creates a ThemeData instance
  const ThemeData({
    required this.name,
    required this.count,
    required this.percentage,
  });
  /// Theme name
  final String name;

  /// Number of games with this theme
  final int count;

  /// Percentage of total games
  final double percentage;

  @override
  List<Object?> get props => [name, count, percentage];
}

/// Game mode statistics
class GameModeStats extends Equatable {

  /// Creates a GameModeStats instance
  const GameModeStats({
    required this.distribution,
    required this.topModes,
  });
  /// Distribution of game modes (mode name -> count)
  final Map<String, int> distribution;

  /// Top game modes sorted by count
  final List<GameModeData> topModes;

  @override
  List<Object?> get props => [distribution, topModes];
}

/// Game mode data entry
class GameModeData extends Equatable {

  /// Creates a GameModeData instance
  const GameModeData({
    required this.name,
    required this.count,
    required this.percentage,
  });
  /// Game mode name
  final String name;

  /// Number of games with this mode
  final int count;

  /// Percentage of total games
  final double percentage;

  @override
  List<Object?> get props => [name, count, percentage];
}

/// Rating statistics
class RatingStats extends Equatable {

  /// Creates a RatingStats instance
  const RatingStats({
    required this.averageRating,
    required this.ratingDistribution,
    required this.totalRatings,
    required this.highestRating,
    required this.lowestRating,
    required this.gamesRated5OrMore,
    required this.gamesRatedBelow5,
  });
  /// Average rating across all rated games
  final double averageRating;

  /// Distribution of ratings (rating -> count)
  final Map<int, int> ratingDistribution;

  /// Total number of ratings
  final int totalRatings;

  /// Highest rating given
  final double highestRating;

  /// Lowest rating given
  final double lowestRating;

  /// Number of games rated 5.0 or more
  final int gamesRated5OrMore;

  /// Number of games rated below 5.0
  final int gamesRatedBelow5;

  @override
  List<Object?> get props => [
        averageRating,
        ratingDistribution,
        totalRatings,
        highestRating,
        lowestRating,
        gamesRated5OrMore,
        gamesRatedBelow5,
      ];
}

/// Developer/Publisher statistics
class DeveloperStats extends Equatable {

  /// Creates a DeveloperStats instance
  const DeveloperStats({
    required this.distribution,
    required this.topDevelopers,
    required this.topPublishers,
  });
  /// Distribution of companies (company name -> count)
  final Map<String, int> distribution;

  /// Top developers sorted by count
  final List<DeveloperData> topDevelopers;

  /// Top publishers sorted by count
  final List<DeveloperData> topPublishers;

  @override
  List<Object?> get props => [distribution, topDevelopers, topPublishers];
}

/// Developer/Publisher data entry
class DeveloperData extends Equatable {

  /// Creates a DeveloperData instance
  const DeveloperData({
    required this.name,
    required this.count,
    required this.percentage,
  });
  /// Company name
  final String name;

  /// Number of games by this company
  final int count;

  /// Percentage of total games
  final double percentage;

  @override
  List<Object?> get props => [name, count, percentage];
}
