// lib/data/repositories/game_repository_impl/repo_user_data.dart
part of '../game_repository_impl.dart';

/// User collection data operations (wishlist/rated/recommended ids and
/// games, rate/toggle/move), entity search and remaining taxonomy lookups.
mixin _RepoUserData on GameRepositoryBase implements GameRepository {
  @override
  Future<Either<Failure, List<Game>>> getUserTopThreeGames(
    String userId,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      // Get top three game IDs from Supabase
      final topThreeIds = await supabaseUserDataSource!.getTopThree(userId);

      if (topThreeIds == null || topThreeIds.isEmpty) {
        return const Right([]);
      }

      // Fetch game details from IGDB
      final gamesResult = await getGamesByIds(topThreeIds);

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
        ServerFailure(message: 'Failed to fetch top three games: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<int>>> getUserRatedGameIds(String userId) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }
    try {
      final ratedGames = await supabaseUserDataSource!.getRatedGames(userId);
      final gameIds = ratedGames.map((e) => e['game_id'] as int).toList();
      return Right(gameIds);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get rated game ids: $e'));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getUserWishlistGameIds(
    String userId,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }
    try {
      final wishlistedGames =
          await supabaseUserDataSource!.getWishlistedGames(userId);
      final gameIds = wishlistedGames.map((e) => e['game_id'] as int).toList();
      return Right(gameIds);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to get wishlisted game ids: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<int>>> getUserRecommendedGameIds(
    String userId,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }
    try {
      final recommendedGames =
          await supabaseUserDataSource!.getRecommendedGames(userId);
      final gameIds = recommendedGames.map((e) => e['game_id'] as int).toList();
      return Right(gameIds);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to get recommended game ids: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRatedGamesByIds({
    required List<int> gameIds,
    required int limit,
    required int offset,
  }) {
    final paginatedGameIds = gameIds.skip(offset).take(limit).toList();
    return getGamesByIds(paginatedGameIds);
  }

  @override
  Future<Either<Failure, List<Game>>> getUserWishlistGamesByIds({
    required List<int> gameIds,
    required int limit,
    required int offset,
  }) {
    final paginatedGameIds = gameIds.skip(offset).take(limit).toList();
    return getGamesByIds(paginatedGameIds);
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRecommendedGamesByIds({
    required List<int> gameIds,
    required int limit,
    required int offset,
  }) {
    final paginatedGameIds = gameIds.skip(offset).take(limit).toList();
    return getGamesByIds(paginatedGameIds);
  }

  @override
  Future<Either<Failure, List<Game>>> getUserWishlist(
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
      // Get wishlisted game IDs from Supabase
      final wishlistData = await supabaseUserDataSource!.getWishlistedGames(
        userId,
        limit: limit,
        offset: offset,
      );

      if (wishlistData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds =
          wishlistData.map((item) => item['game_id'] as int).toList();

      // Fetch game details from IGDB
      final gamesResult = await getGamesByIds(gameIds);

      return gamesResult.fold(
        Left.new,
        (games) async {
          // Enrich with user data if enrichment service available
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
      return Left(ServerFailure(message: 'Failed to fetch wishlist: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserWishlistWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  }) {
    // For now, just return regular wishlist
    // TODO: Apply filters when Supabase queries support filtering
    return getUserWishlist(userId, limit, offset);
  }

  @override
  Future<Either<Failure, List<Game>>> getWishlistRecentReleases(
    String userId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Get user's wishlist
    final wishlistResult = await getUserWishlist(userId, 100, 0);

    return wishlistResult.fold(
      Left.new,
      (games) {
        // Filter games by release date
        final now = DateTime.now();
        final from = fromDate ?? now.subtract(const Duration(days: 30));
        final to = toDate ?? now.add(const Duration(days: 14));

        final filteredGames = games.where((game) {
          if (game.firstReleaseDate == null) return false;
          final releaseDate = game.firstReleaseDate!;
          return releaseDate.isAfter(from) && releaseDate.isBefore(to);
        }).toList();

        return Right(filteredGames);
      },
    );
  }

  @override
  Future<Either<Failure, void>> moveGamesBetweenCollections({
    required String userId,
    required List<int> gameIds,
    required UserCollectionType fromCollection,
    required UserCollectionType toCollection,
  }) async {
    // For now, this is a stub implementation
    // TODO: Implement actual collection movement logic
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> rateGame(
    int gameId,
    String userId,
    double rating,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      await supabaseUserDataSource!.rateGame(userId, gameId, rating);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: 'Failed to rate game: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearchQuery(
    String userId,
    String query,
  ) async {
    // For now, this is a stub implementation
    // TODO: Implement search query saving
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Character>>> searchCharacters(String query) {
    return executeIgdbOperation(
      operation: () async {
        final characterQuery = CharacterQueryPresets.search(
          searchTerm: query,
        );
        return igdbDataSource.queryCharacters(characterQuery);
      },
      errorMessage: 'Failed to search characters',
    );
  }

  @override
  Future<Either<Failure, List<Event>>> searchEvents(String query) {
    return executeIgdbOperation(
      operation: () async {
        final eventQuery = EventQueryPresets.search(
          searchTerm: query,
        );
        return igdbDataSource.queryEvents(eventQuery);
      },
      errorMessage: 'Failed to search events',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> searchGamesWithFilters({
    required String query,
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  }) {
    // Reuse advancedGameSearch with text query
    return advancedGameSearch(
      textQuery: query,
      filters: filters,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Either<Failure, List<Game>>> searchUserCollections({
    required String userId,
    required String query,
    required List<UserCollectionType> collectionTypes,
    UserCollectionFilters? filters,
    int limit = 20,
    int offset = 0,
  }) async {
    // Get all collections and filter by search query
    final collectionsResult = await getAllUserCollections(
      userId: userId,
      limitPerCollection: 100,
    );

    return collectionsResult.fold(
      Left.new,
      (collections) {
        final allGames = <Game>[];

        // Collect games from requested collection types
        for (final type in collectionTypes) {
          final games = collections[type] ?? [];
          allGames.addAll(games);
        }

        // Filter by search query
        final searchLower = query.toLowerCase();
        final filteredGames = allGames.where((game) {
          return game.name.toLowerCase().contains(searchLower);
        }).toList();

        // Apply limit and offset
        final start = offset.clamp(0, filteredGames.length);
        final end = (offset + limit).clamp(0, filteredGames.length);
        final paginatedGames = filteredGames.sublist(start, end);

        return Right(paginatedGames);
      },
    );
  }

  @override
  Future<Either<Failure, void>> toggleRecommend(
    int gameId,
    String userId,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      await supabaseUserDataSource!.toggleRecommended(userId, gameId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: 'Failed to toggle recommend: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleWishlist(
    int gameId,
    String userId,
  ) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      await supabaseUserDataSource!.toggleWishlist(userId, gameId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: 'Failed to toggle wishlist: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GameMode>>> getAllGameModes() {
    return executeIgdbOperation(
      operation: () async {
        // Query all game modes from IGDB
        const query = IgdbGameModeQuery(
          limit: 100,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryGameModes(query);
        return result;
      },
      errorMessage: 'Failed to fetch game modes',
    );
  }

  @override
  Future<Either<Failure, List<GameStatus>>> getAllGameStatuses() {
    return executeIgdbOperation(
      operation: () async {
        // Query all game statuses from IGDB
        const query = IgdbGameStatusQuery(
          limit: 100,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryGameStatuses(query);
        return result;
      },
      errorMessage: 'Failed to fetch game statuses',
    );
  }

  @override
  Future<Either<Failure, List<GameType>>> getAllGameTypes() {
    return executeIgdbOperation(
      operation: () async {
        // Query all game types from IGDB
        const query = IgdbGameTypeQuery(
          limit: 100,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryGameTypes(query);
        return result;
      },
      errorMessage: 'Failed to fetch game types',
    );
  }

  @override
  Future<Either<Failure, List<PlayerPerspective>>> getAllPlayerPerspectives() {
    return executeIgdbOperation(
      operation: () async {
        // Query all player perspectives from IGDB
        const query = IgdbPlayerPerspectiveQuery(
          limit: 100,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryPlayerPerspectives(query);
        return result;
      },
      errorMessage: 'Failed to fetch player perspectives',
    );
  }

  @override
  Future<Either<Failure, List<AgeRatingCategory>>> searchAgeRatings(
    String query,
  ) {
    return executeIgdbOperation(
      operation: () async {
        // Create multiple filters for different fields (OR logic)
        // Search in: organization name, rating category, and content descriptions
        final multiFieldFilter = CombinedFilter(
          [
            FieldFilter('organization.name', '~', query),
            FieldFilter('rating', '~', query),
          ],
          operator: '|',
        ); // Use OR operator to match ANY field

        final igdbQuery = IgdbAgeRatingQuery(
          where: multiFieldFilter,
          fields: const [
            '*',
            'organization.*',
          ],
          sort: 'organization.name asc',
        );
        final result = await igdbDataSource.queryAgeRatings(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to search age ratings',
    );
  }

  @override
  Future<Either<Failure, List<IGDBTheme>>> searchThemes(String query) {
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbThemeQuery(
          where: filter,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryThemes(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to search themes',
    );
  }
}
