// lib/data/repositories/game_repository_impl/repo_media_facets.dart
part of '../game_repository_impl.dart';

/// Filtered games, per-game media/details (artwork, screenshots, videos,
/// websites, age ratings, events) and games-by-facet queries.
mixin _RepoMediaFacets on GameRepositoryBase implements GameRepository {
  @override
  Future<Either<Failure, List<Game>>> getFilteredGames({
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  }) {
    // Reuse advancedGameSearch without text query
    return advancedGameSearch(
      filters: filters,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Either<Failure, List<AgeRating>>> getGameAgeRatings(
    List<int> gameIds,
  ) {
    if (gameIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        // First get games with age_ratings field
        final gameQuery = IgdbGameQuery(
          where: ContainsFilter('id', gameIds),
          fields: const ['age_ratings.*'],
          limit: gameIds.length,
        );
        final games = await igdbDataSource.queryGames(gameQuery);

        // Collect all age ratings from all games
        final allRatings = <AgeRating>[];
        for (final game in games) {
          allRatings.addAll(game.ageRatings);
        }

        return allRatings;
      },
      errorMessage: 'Failed to fetch game age ratings',
    );
  }

  @override
  Future<Either<Failure, List<Artwork>>> getGameArtwork(int gameId) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = IgdbGameQuery(
          where: FieldFilter('id', '=', gameId),
          fields: const ['artworks.*'],
          limit: 1,
        );
        final games = await igdbDataSource.queryGames(query);

        if (games.isEmpty) {
          return <Artwork>[];
        }

        return games.first.artworks;
      },
      errorMessage: 'Failed to fetch game artwork',
    );
  }

  @override
  Future<Either<Failure, List<Character>>> getGameCharacters(int gameId) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = CharacterQueryPresets.fromGame(
          gameId: gameId,
          limit: 100,
        );
        return igdbDataSource.queryCharacters(query);
      },
      errorMessage: 'Failed to fetch game characters',
    );
  }

  @override
  Future<Either<Failure, GameEngine>> getGameEngineDetails(int gameEngineId) {
    if (gameEngineId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game engine ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = GameEngineQueryPresets.fullDetails(
          gameEngineId: gameEngineId,
        );
        final engines = await igdbDataSource.queryGameEngines(query);

        if (engines.isEmpty) {
          throw const IgdbNotFoundException(message: 'Game engine not found');
        }

        return engines.first;
      },
      errorMessage: 'Failed to fetch game engine details',
    );
  }

  @override
  Future<Either<Failure, List<Event>>> getGameEvents(int gameId) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = EventQueryPresets.byGame(
          gameId: gameId,
        );
        return igdbDataSource.queryEvents(query);
      },
      errorMessage: 'Failed to fetch game events',
    );
  }

  @override
  Future<Either<Failure, GameMediaCollection>> getGameMediaCollection(
    int gameId,
  ) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = IgdbGameQuery(
          where: FieldFilter('id', '=', gameId),
          fields: const ['artworks.*', 'screenshots.*', 'videos.*'],
          limit: 1,
        );
        final games = await igdbDataSource.queryGames(query);

        if (games.isEmpty) {
          throw const IgdbNotFoundException(message: 'Game not found');
        }

        final game = games.first;
        return GameMediaCollection(
          gameId: gameId,
          artworks: game.artworks,
          screenshots: game.screenshots,
          videos: game.videos,
        );
      },
      errorMessage: 'Failed to fetch game media collection',
    );
  }

  @override
  Future<Either<Failure, List<Screenshot>>> getGameScreenshots(int gameId) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = IgdbGameQuery(
          where: FieldFilter('id', '=', gameId),
          fields: const ['screenshots.*'],
          limit: 1,
        );
        final games = await igdbDataSource.queryGames(query);

        if (games.isEmpty) {
          return <Screenshot>[];
        }

        return games.first.screenshots;
      },
      errorMessage: 'Failed to fetch game screenshots',
    );
  }

  @override
  Future<Either<Failure, List<GameVideo>>> getGameVideos(int gameId) {
    if (gameId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid game ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = IgdbGameQuery(
          where: FieldFilter('id', '=', gameId),
          fields: const ['videos.*'],
          limit: 1,
        );
        final games = await igdbDataSource.queryGames(query);

        if (games.isEmpty) {
          return <GameVideo>[];
        }

        return games.first.videos;
      },
      errorMessage: 'Failed to fetch game videos',
    );
  }

  @override
  Future<Either<Failure, List<Website>>> getGameWebsites(List<int> gameIds) {
    if (gameIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final query = IgdbGameQuery(
          where: ContainsFilter('id', gameIds),
          fields: const ['websites.*'],
          limit: gameIds.length,
        );
        final games = await igdbDataSource.queryGames(query);

        // Collect all websites from all games
        final allWebsites = <Website>[];
        for (final game in games) {
          allWebsites.addAll(game.websites);
        }

        return allWebsites;
      },
      errorMessage: 'Failed to fetch game websites',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByCharacter(int characterId) {
    if (characterId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid character ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        // First get the character with games field
        final characterQuery = IgdbCharacterQuery(
          where: FieldFilter('id', '=', characterId),
          fields: const ['games'],
          limit: 1,
        );
        final characterResult =
            await igdbDataSource.queryCharacters(characterQuery);

        if (characterResult.isEmpty ||
            characterResult.first.games == null ||
            characterResult.first.games!.isEmpty) {
          return <Game>[];
        }

        // Extract game IDs and fetch full details
        final gameIds =
            characterResult.first.games!.map((game) => game.id).toList();
        final gameQuery = IgdbGameQuery(
          where: ContainsFilter('id', gameIds),
          fields: GameFieldSets.standard,
          limit: gameIds.length,
        );
        return igdbDataSource.queryGames(gameQuery);
      },
      errorMessage: 'Failed to fetch games by character',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByGameEngine({
    required List<int> gameEngineIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.popularity,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    if (gameEngineIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final filter = CombinedFilter([
          ContainsFilter('game_engines', gameEngineIds),
        ]);

        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: limit,
          offset: offset,
          sort: 'total_rating_count desc',
        );

        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by game engine',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByRatingRange({
    required double minRating,
    required double maxRating,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.rating,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    return executeIgdbOperation(
      operation: () async {
        final filter = CombinedFilter([
          GameFilters.mainGamesOnly(),
          FieldFilter('total_rating', '>=', minRating * 10),
          FieldFilter('total_rating', '<=', maxRating * 10),
          GameFilters.minRatingCount(10),
        ]);

        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: limit,
          offset: offset,
          sort: sortOrder == SortOrder.descending
              ? 'total_rating desc'
              : 'total_rating asc',
        );

        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by rating range',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByReleaseYear({
    required int fromYear,
    required int toYear,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.releaseDate,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    return executeIgdbOperation(
      operation: () async {
        final startDate = DateTime(fromYear);
        final endDate = DateTime(toYear, 12, 31, 23, 59, 59);

        final filter = CombinedFilter([
          GameFilters.mainGamesOnly(),
          GameFilters.releasedAfter(startDate),
          GameFilters.releasedBefore(endDate),
        ]);

        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: limit,
          offset: offset,
          sort: sortOrder == SortOrder.descending
              ? 'first_release_date desc'
              : 'first_release_date asc',
        );

        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by release year',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getNewestGames(int limit, int offset) {
    return executeIgdbOperation(
      operation: () async {
        final query = GameQueryPresets.recentReleases(
          limit: limit,
          offset: offset,
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch newest games',
    );
  }
}
