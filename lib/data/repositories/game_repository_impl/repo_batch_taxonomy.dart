// lib/data/repositories/game_repository_impl/repo_batch_taxonomy.dart
part of '../game_repository_impl.dart';

/// Batch user-collection writes, taxonomy lookups
/// (genres/platforms/engines/franchises/collections/keywords/age-ratings/languages),
/// user collection summaries, characters, companies and events.
mixin _RepoBatchTaxonomy on GameRepositoryBase implements GameRepository {
  @override
  Future<Either<Failure, void>> batchAddToWishlist({
    required String userId,
    required List<int> gameIds,
  }) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      // Add each game to wishlist
      for (final gameId in gameIds) {
        await supabaseUserDataSource!.toggleWishlist(userId, gameId);
      }
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to batch add to wishlist: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> batchRateGames({
    required String userId,
    required Map<int, double> gameRatings,
  }) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      // Rate each game
      for (final entry in gameRatings.entries) {
        await supabaseUserDataSource!.rateGame(
          userId,
          entry.key,
          entry.value,
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to batch rate games: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> batchRemoveFromWishlist({
    required String userId,
    required List<int> gameIds,
  }) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      // Remove each game from wishlist
      for (final gameId in gameIds) {
        await supabaseUserDataSource!.toggleWishlist(userId, gameId);
      }
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to batch remove from wishlist: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Genre>>> getAllGenres() {
    return executeIgdbOperation(
      operation: () async {
        // Query all genres from IGDB
        const query = IgdbGenreQuery(
          limit: 100,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryGenres(query);
        return result;
      },
      errorMessage: 'Failed to fetch genres',
    );
  }

  @override
  Future<Either<Failure, List<Platform>>> getAllPlatforms() {
    return executeIgdbOperation(
      operation: () async {
        final query = PlatformQueryPresets.basicList(
          limit: 200,
        );
        final result = await igdbDataSource.queryPlatforms(query);
        return result;
      },
      errorMessage: 'Failed to fetch platforms',
    );
  }

  @override
  Future<Either<Failure, List<Genre>>> searchGenres(String query) {
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbGenreQuery(
          where: filter,
          limit: 50,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryGenres(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to search genres',
    );
  }

  @override
  Future<Either<Failure, List<Platform>>> searchPlatforms(String query) {
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = PlatformQueryPresets.basicList(
          filter: filter,
          limit: 50,
        );
        final result = await igdbDataSource.queryPlatforms(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to search platforms',
    );
  }

  @override
  Future<Either<Failure, List<GameEngine>>> searchGameEngines(String query) {
    return executeIgdbOperation(
      operation: () async {
        final igdbQuery = GameEngineQueryPresets.search(
          searchTerm: query,
        );
        final result = await igdbDataSource.queryGameEngines(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to search game engines',
    );
  }

  @override
  Future<Either<Failure, List<Franchise>>> searchFranchises(String query) {
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbFranchiseQuery(
          where: filter,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryFranchises(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to search franchises',
    );
  }

  @override
  Future<Either<Failure, List<Collection>>> searchCollections(String query) {
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbCollectionQuery(
          where: filter,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryCollections(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to search collections',
    );
  }

  @override
  Future<Either<Failure, List<Keyword>>> searchKeywords(String query) {
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbKeywordQuery(
          where: filter,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryKeywords(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to search keywords',
    );
  }

  @override
  Future<Either<Failure, List<AgeRatingCategory>>> getAllAgeRatings() {
    return executeIgdbOperation(
      operation: () async {
        const igdbQuery = IgdbAgeRatingQuery(
          fields: ['*', 'rating_category.*', 'organization.*'],
          limit: 100,
          sort: 'organization asc',
        );
        final result = await igdbDataSource.queryAgeRatings(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to get age ratings',
    );
  }

  @override
  Future<Either<Failure, List<Language>>> searchLanguages(
    String query,
  ) {
    return executeIgdbOperation(
      operation: () async {
        final multiFieldFilter = CombinedFilter(
          [
            FieldFilter('name', '~', query),
            FieldFilter('native_name', '~', query),
          ],
          operator: '|',
        ); // Use OR operator to match ANY field

        final igdbQuery = IgdbLanguageQuery(
          where: multiFieldFilter,
          sort: 'name asc',
        );
        final result = await igdbDataSource.queryLanguages(igdbQuery);
        return result;
      },
      errorMessage: 'Failed to search languages',
    );
  }

  @override
  Future<Either<Failure, Map<UserCollectionType, UserCollectionSummary>>>
      getAllUserCollectionSummaries(String userId) async {
    if (supabaseUserDataSource == null) {
      return const Left(
        ServerFailure(message: 'User datasource not available'),
      );
    }

    try {
      // Get collection stats from Supabase
      final stats = await supabaseUserDataSource!.getCollectionStats(userId);

      final summaries = <UserCollectionType, UserCollectionSummary>{
        UserCollectionType.wishlist: UserCollectionSummary(
          type: UserCollectionType.wishlist,
          totalCount: stats['total_games_wishlisted'] as int? ?? 0,
        ),
        UserCollectionType.rated: UserCollectionSummary(
          type: UserCollectionType.rated,
          totalCount: stats['total_games_rated'] as int? ?? 0,
        ),
        UserCollectionType.recommended: UserCollectionSummary(
          type: UserCollectionType.recommended,
          totalCount: stats['total_games_recommended'] as int? ?? 0,
        ),
      };

      return Right(summaries);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to fetch collection summaries: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<UserCollectionType, List<Game>>>>
      getAllUserCollections({
    required String userId,
    int limitPerCollection = 10,
  }) async {
    try {
      // Fetch all collections in parallel
      final results = await Future.wait([
        getUserWishlist(userId, limitPerCollection, 0),
        getUserRated(userId, limitPerCollection, 0),
        getUserRecommendations(userId, limitPerCollection, 0),
      ]);

      final collections = <UserCollectionType, List<Game>>{};

      // Process wishlist
      results[0].fold(
        (_) => collections[UserCollectionType.wishlist] = [],
        (games) => collections[UserCollectionType.wishlist] = games,
      );

      // Process rated
      results[1].fold(
        (_) => collections[UserCollectionType.rated] = [],
        (games) => collections[UserCollectionType.rated] = games,
      );

      // Process recommended
      results[2].fold(
        (_) => collections[UserCollectionType.recommended] = [],
        (games) => collections[UserCollectionType.recommended] = games,
      );

      return Right(collections);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to fetch user collections: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Character>> getCharacterDetails(int characterId) {
    if (characterId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid character ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = CharacterQueryPresets.fullDetails(
          characterId: characterId,
        );
        final characters = await igdbDataSource.queryCharacters(query);

        if (characters.isEmpty) {
          throw const IgdbNotFoundException(message: 'Character not found');
        }

        return characters.first;
      },
      errorMessage: 'Failed to fetch character details',
    );
  }

  @override
  Future<Either<Failure, List<Character>>> getCharactersByGender(
    CharacterGenderEnum gender,
  ) {
    return executeIgdbOperation(
      operation: () async {
        final query = CharacterQueryPresets.byGender(
          gender: gender,
          limit: 50,
        );
        return igdbDataSource.queryCharacters(query);
      },
      errorMessage: 'Failed to fetch characters by gender',
    );
  }

  @override
  Future<Either<Failure, List<Character>>> getCharactersBySpecies(
    CharacterSpeciesEnum species,
  ) {
    return executeIgdbOperation(
      operation: () async {
        final query = CharacterQueryPresets.bySpecies(
          species: species,
          limit: 50,
        );
        return igdbDataSource.queryCharacters(query);
      },
      errorMessage: 'Failed to fetch characters by species',
    );
  }

  @override
  Future<Either<Failure, List<Company>>> getCompanies({
    List<int>? ids,
    String? search,
  }) {
    return executeIgdbOperation(
      operation: () async {
        IgdbCompanyQuery query;

        if (ids != null && ids.isNotEmpty) {
          // Query by IDs
          final filter = ContainsFilter('id', ids);
          query = CompanyQueryPresets.basicList(
            filter: filter,
            limit: ids.length,
          );
        } else if (search != null && search.trim().isNotEmpty) {
          // Query by search term
          query = CompanyQueryPresets.search(
            searchTerm: search.trim(),
          );
        } else {
          // Return all companies (limited)
          query = CompanyQueryPresets.basicList(
            limit: 100,
          );
        }

        final result = await igdbDataSource.queryCompanies(query);
        return result;
      },
      errorMessage: 'Failed to fetch companies',
    );
  }

  @override
  Future<Either<Failure, Company>> getCompanyDetails(
    int companyId,
    String? userId,
  ) {
    if (companyId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid company ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = CompanyQueryPresets.fullDetails(
          companyId: companyId,
        );
        final companies = await igdbDataSource.queryCompanies(query);

        if (companies.isEmpty) {
          throw const IgdbNotFoundException(message: 'Company not found');
        }

        return companies.first;
      },
      errorMessage: 'Failed to fetch company details',
    );
  }

  @override
  Future<Either<Failure, Game>> getEnhancedGameDetails({
    required int gameId,
    String? userId,
    bool includeCharacters = true,
    bool includeEvents = true,
    bool includeMedia = true,
  }) async {
    if (gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    // Get base game details with user data
    final gameResult = await getCompleteGameDetails(gameId, userId);

    return gameResult.fold(
      Left.new,
      (game) async {
        // Game is already fetched with full details from GameQueryPresets.fullDetails
        // which includes characters, events, and media by default
        // So we just return it as-is
        return Right(game);
      },
    );
  }

  @override
  Future<Either<Failure, Event>> getEventDetails(int eventId) {
    if (eventId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid event ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = EventQueryPresets.fullDetails(eventId: eventId);
        final events = await igdbDataSource.queryEvents(query);

        if (events.isEmpty) {
          throw const IgdbNotFoundException(message: 'Event not found');
        }

        return events.first;
      },
      errorMessage: 'Failed to fetch event details',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getEventGames(int eventId) {
    if (eventId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid event ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        // First get the event with games field
        final eventQuery = IgdbEventQuery(
          where: FieldFilter('id', '=', eventId),
          fields: const ['games'],
          limit: 1,
        );
        final eventResult = await igdbDataSource.queryEvents(eventQuery);

        if (eventResult.isEmpty || eventResult.first.games.isEmpty) {
          return <Game>[];
        }

        // Extract game IDs and fetch full details
        final gameIds = eventResult.first.games.map((game) => game.id).toList();
        final gameQuery = IgdbGameQuery(
          where: ContainsFilter('id', gameIds),
          fields: GameFieldSets.standard,
          limit: gameIds.length,
        );
        return igdbDataSource.queryGames(gameQuery);
      },
      errorMessage: 'Failed to fetch event games',
    );
  }
}
