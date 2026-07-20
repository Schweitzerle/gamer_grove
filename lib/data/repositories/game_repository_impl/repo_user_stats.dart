// lib/data/repositories/game_repository_impl/repo_user_stats.dart
part of '../game_repository_impl.dart';

/// Platform/character details plus user gaming statistics, analytics, genre
/// preferences and recommendations.
mixin _RepoUserStats on GameRepositoryBase implements GameRepository {
  @override
  Future<Either<Failure, Platform>> getPlatformDetails(int platformId) {
    if (platformId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid platform ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = PlatformQueryPresets.fullDetails(
          platformId: platformId,
        );
        final platforms = await igdbDataSource.queryPlatforms(query);

        if (platforms.isEmpty) {
          throw const IgdbNotFoundException(message: 'Platform not found');
        }

        return platforms.first;
      },
      errorMessage: 'Failed to fetch platform details',
    );
  }

  @override
  Future<Either<Failure, List<Character>>> getPopularCharacters({
    int limit = 20,
  }) {
    return executeIgdbOperation(
      operation: () async {
        final query = CharacterQueryPresets.popular(
          limit: limit,
        );
        return igdbDataSource.queryCharacters(query);
      },
      errorMessage: 'Failed to fetch popular characters',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getRecentSearches(
    String userId, {
    int limit = 10,
  }) async {
    // For now, return empty list
    // TODO: Implement recent searches from saved search history
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Game>>> getRecentlyAddedToCollections({
    required String userId,
    int days = 7,
    int limit = 20,
  }) async {
    // For now, return empty list
    // TODO: Implement recent additions tracking
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions(
    String partialQuery,
  ) async {
    // For now, return empty list
    // TODO: Implement search suggestions based on popular searches
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserActivityTimeline({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      final activity = await supabaseUserDataSource!.getUserActivity(
        userId,
        limit: limit,
        offset: 0,
      );
      return Right(activity);
    } on Exception catch (e) {
      return Left(
        ServerFailure(message: 'Failed to fetch activity timeline: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, UserCollectionSummary>> getUserCollectionSummary({
    required String userId,
    required UserCollectionType collectionType,
  }) async {
    final summariesResult = await getAllUserCollectionSummaries(userId);

    return summariesResult.fold(
      Left.new,
      (summaries) {
        final summary = summaries[collectionType];
        if (summary != null) {
          return Right(summary);
        }
        return const Left(
          ServerFailure(message: 'Collection summary not found'),
        );
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserGamingStatistics(
    String userId,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      final stats = await supabaseUserDataSource!.getUserStats(userId);
      return Right(stats);
    } on Exception catch (e) {
      return Left(
        ServerFailure(message: 'Failed to fetch gaming statistics: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getUserGenrePreferences(
    String userId,
  ) async {
    // For now, return empty map
    // TODO: Implement genre preference calculation
    return const Right({});
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUserPlatformStatistics(
    String userId,
  ) async {
    // For now, return empty map
    // TODO: Implement platform statistics calculation
    return const Right({});
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRated(
    String userId,
    int limit,
    int offset,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      // Get rated game IDs from Supabase
      final ratedData = await supabaseUserDataSource!.getRatedGames(
        userId,
        limit: limit,
        offset: offset,
      );

      if (ratedData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds = ratedData.map((item) => item['game_id'] as int).toList();

      // Fetch game details from IGDB
      final gamesResult = await getGamesByIds(gameIds);

      return gamesResult.fold(
        Left.new,
        (games) async {
          // Enrich with user data
          if (enrichmentService != null) {
            try {
              final enriched =
                  await enrichmentService!.enrichGames(games, userId);
              return Right(enriched);
            } catch (e) {
              return Right(games);
            }
          }
          return Right(games);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch rated games: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRatedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  }) {
    // For now, just return regular rated games
    // TODO: Apply filters when Supabase queries support filtering
    return getUserRated(userId, limit, offset);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserRatingAnalytics(
    String userId,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      final stats = await supabaseUserDataSource!.getCollectionStats(userId);

      // Extract rating-specific analytics
      final analytics = <String, dynamic>{
        'total_rated': stats['total_games_rated'] ?? 0,
        'average_rating': stats['average_rating'] ?? 0.0,
      };

      return Right(analytics);
    } on Exception catch (e) {
      return Left(
        ServerFailure(message: 'Failed to fetch rating analytics: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRecommendations(
    String userId,
    int limit,
    int offset,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      // Get recommended game IDs from Supabase
      final recommendedData = await supabaseUserDataSource!.getRecommendedGames(
        userId,
        limit: limit,
        offset: offset,
      );

      if (recommendedData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds =
          recommendedData.map((item) => item['game_id'] as int).toList();

      // Fetch game details from IGDB
      final gamesResult = await getGamesByIds(gameIds);

      return gamesResult.fold(
        Left.new,
        (games) async {
          // Enrich with user data
          if (enrichmentService != null) {
            try {
              final enriched =
                  await enrichmentService!.enrichGames(games, userId);
              return Right(enriched);
            } catch (e) {
              return Right(games);
            }
          }
          return Right(games);
        },
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to fetch recommendations: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRecommendedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  }) {
    // For now, just return regular recommended games
    // TODO: Apply filters when Supabase queries support filtering
    return getUserRecommendations(userId, limit, offset);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserTopGenres({
    required String userId,
    int limit = 10,
  }) async {
    // For now, return empty list
    // TODO: Implement top genres calculation from user's collections
    return const Right([]);
  }
}
