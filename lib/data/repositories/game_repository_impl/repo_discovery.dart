// lib/data/repositories/game_repository_impl/repo_discovery.dart
part of '../game_repository_impl.dart';

/// Basic game lookup, popularity/discovery, and related-game queries.
mixin _RepoDiscovery on GameRepositoryBase implements GameRepository {
  // ============================================================
  // BASIC GAME METHODS
  // ============================================================

  @override
  Future<Either<Failure, List<Game>>> searchGames(
    String query,
    int limit,
    int offset,
  ) {
    if (query.trim().isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final searchQuery = GameQueryPresets.search(
          searchTerm: query.trim(),
          limit: limit,
          offset: offset,
        );
        return igdbDataSource.queryGames(searchQuery);
      },
      errorMessage: 'Failed to search games',
    );
  }

  @override
  Future<Either<Failure, Game>> getGameDetails(int gameId) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = GameQueryPresets.fullDetails(gameId: gameId);
        final games = await igdbDataSource.queryGames(query);

        if (games.isEmpty) {
          throw const IgdbNotFoundException(message: 'Game not found');
        }

        final charactersResult = await getGameCharacters(gameId);
        final eventResult = await getGameEvents(gameId);
        final game = games.first;

        // Enrich the immutable game with its characters/events (empty on
        // failure) via copyWith instead of mutating the shared entity.
        return game.copyWith(
          characters: charactersResult.getOrElse(() => const []),
          events: eventResult.getOrElse(() => const []),
        );
      },
      errorMessage: 'Failed to fetch game details',
    );
  }

  @override
  Future<Either<Failure, Game>> getCompleteGameDetails(
    int gameId,
    String? userId,
  ) async {
    final result = await getGameDetails(gameId);

    // Enrich with user data if userId provided and enrichment service available
    if (userId != null && enrichmentService != null) {
      return result.fold(
        Left.new,
        (game) async {
          try {
            final enriched = await enrichmentService!.enrichGames(
              [game],
              userId,
            );
            return Right(enriched.first);
          } catch (e) {
            // Return game without enrichment on error
            return Right(game);
          }
        },
      );
    }

    return result;
  }

  @override
  Future<Either<Failure, Game>> getGameDetailsWithUserData(
    int gameId,
    String? userId,
  ) {
    return getCompleteGameDetails(gameId, userId);
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByIds(List<int> gameIds) {
    if (gameIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final filter = ContainsFilter('id', gameIds);
        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: gameIds.length,
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by IDs',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getGames({required List<int> gameIds}) {
    if (gameIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final filter = ContainsFilter('id', gameIds);
        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: gameIds.length,
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by IDs',
    );
  }

  // ============================================================
  // POPULAR & DISCOVERY METHODS
  // ============================================================

  @override
  Future<Either<Failure, List<Game>>> getPopularGames(
    int limit,
    int offset,
  ) {
    return executeIgdbOperation(
      operation: () async {
        final query = GameQueryPresets.popular(
          limit: limit,
          offset: offset,
        );
        final result = await igdbDataSource.queryGames(query);
        return result;
      },
      errorMessage: 'Failed to fetch popular games',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getUpcomingGames(
    int limit,
    int offset,
  ) {
    return executeIgdbOperation(
      operation: () async {
        final query = GameQueryPresets.upcomingReleases(
          limit: limit,
          offset: offset,
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch upcoming games',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getLatestGames(
    int limit,
    int offset,
  ) {
    return executeIgdbOperation(
      operation: () async {
        final query = GameQueryPresets.recentReleases(
          limit: limit,
          offset: offset,
          daysAgo: 90,
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch latest games',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getTopRatedGames(
    int limit,
    int offset,
  ) {
    return executeIgdbOperation(
      operation: () async {
        final query = GameQueryPresets.topRated(
          limit: limit,
          offset: offset,
          minRating: 80,
          minRatingCount: 50,
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch top rated games',
    );
  }

  // ============================================================
  // RELATED GAMES
  // ============================================================

  @override
  Future<Either<Failure, List<Game>>> getSimilarGames(int gameId) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        // First get the game with similar_games field
        final gameQuery = IgdbGameQuery(
          where: FieldFilter('id', '=', gameId),
          fields: const ['similar_games'],
          limit: 1,
        );
        final gameResult = await igdbDataSource.queryGames(gameQuery);

        if (gameResult.isEmpty || gameResult.first.similarGames.isEmpty) {
          return <Game>[];
        }

        // Extract IDs from similar games and fetch full details
        final similarGameIds =
            gameResult.first.similarGames.map((game) => game.id).toList();
        final query = GameQueryPresets.similarGames(
          gameIds: similarGameIds,
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch similar games',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getGameDLCs(int gameId) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final filter = GameFilters.dlcsOf(gameId);
        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: 50,
          sort: 'first_release_date desc',
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch game DLCs',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getGameExpansions(int gameId) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final filter = CombinedFilter([
          GameFilters.dlcsOf(gameId),
          GameFilters.expansionsOnly(),
        ]);
        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: 50,
          sort: 'first_release_date desc',
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch game expansions',
    );
  }
}
