// lib/data/repositories/game_repository_impl/repo_by_entity.dart
part of '../game_repository_impl.dart';

/// Games filtered by platform/genre/company/franchise/collection and the
/// advanced multi-facet search.
mixin _RepoByEntity on GameRepositoryBase implements GameRepository {
  // ============================================================
  // GAMES BY ENTITY
  // ============================================================

  @override
  Future<Either<Failure, List<Game>>> getGamesByPlatform({
    required List<int> platformIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.popularity,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    if (platformIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final query = GameQueryPresets.byPlatform(
          platformId: platformIds.first,
          limit: limit,
          offset: offset,
          onlyMainGames:
              false, // 🔧 Include all game types (ports, remasters, etc.)
          sortBy: sortBy.igdbField, // 🔧 Pass sorting parameters
          sortOrder: sortOrder.value,
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by platform',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByGenre({
    required List<int> genreIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.popularity,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    if (genreIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final query = GameQueryPresets.byGenre(
          genreId: genreIds.first,
          limit: limit,
          offset: offset,
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by genre',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByCompany({
    required List<int> companyIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.popularity,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    if (companyIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final filter = GameFilters.byCompany(companyIds.first);
        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: limit,
          offset: offset,
          sort: 'total_rating_count desc',
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by company',
    );
  }

  // Not in interface - repository-specific method
  Future<Either<Failure, List<Game>>> getGamesByFranchise({
    required int franchiseId,
    int limit = 20,
    int offset = 0,
  }) {
    if (franchiseId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid franchise ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final filter = GameFilters.byFranchise(franchiseId);
        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: limit,
          offset: offset,
          sort: 'first_release_date desc',
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by franchise',
    );
  }

  // Not in interface - repository-specific method
  Future<Either<Failure, List<Game>>> getGamesByCollection({
    required int collectionId,
    int limit = 20,
    int offset = 0,
  }) {
    if (collectionId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid collection ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final filter = GameFilters.byCollection(collectionId);
        final query = IgdbGameQuery(
          where: filter,
          fields: GameFieldSets.standard,
          limit: limit,
          offset: offset,
          sort: 'first_release_date desc',
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch games by collection',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> advancedGameSearch({
    required SearchFilters filters,
    String? textQuery,
    int limit = 20,
    int offset = 0,
  }) {
    return executeIgdbOperation(
      operation: () async {
        // Build combined filters from SearchFilters
        final igdbFilters = <IgdbFilter>[
          //GameFilters.mainGamesOnly(),
        ];

        // Add text search if provided
        if (textQuery != null && textQuery.trim().isNotEmpty) {
          final nameFilter = GameFilters.searchByName(textQuery.trim());
          igdbFilters.add(nameFilter);
        }

        // ========== BASIC FILTERS ==========
        // Genre filters
        if (filters.genreIds.isNotEmpty) {
          final genreFilter = ContainsFilter('genres', filters.genreIds);
          igdbFilters.add(genreFilter);
        }

        // Platform filters
        if (filters.platformIds.isNotEmpty) {
          final platformFilter =
              ContainsFilter('platforms', filters.platformIds);
          igdbFilters.add(platformFilter);
        }

        // Release date filters
        if (filters.releaseDateFrom != null) {
          final dateFilter =
              GameFilters.releasedAfter(filters.releaseDateFrom!);
          igdbFilters.add(dateFilter);
        }
        if (filters.releaseDateTo != null) {
          final dateFilter = GameFilters.releasedBefore(filters.releaseDateTo!);
          igdbFilters.add(dateFilter);
        }

        // ========== RATING FILTERS ==========
        // Total Rating (user + critic combined)
        if (filters.minTotalRating != null) {
          final filter = FieldFilter(
            'total_rating',
            '>=',
            filters.minTotalRating!.toInt() * 10,
          );
          igdbFilters.add(filter);
        }
        if (filters.maxTotalRating != null) {
          final filter = FieldFilter(
            'total_rating',
            '<=',
            filters.maxTotalRating!.toInt() * 10,
          );
          igdbFilters.add(filter);
        }
        if (filters.minTotalRatingCount != null) {
          final filter = FieldFilter(
            'total_rating_count',
            '>=',
            filters.minTotalRatingCount,
          );
          igdbFilters.add(filter);
        }

        // IGDB User Rating
        if (filters.minUserRating != null) {
          final filter =
              FieldFilter('rating', '>=', filters.minUserRating!.toInt() * 10);
          igdbFilters.add(filter);
        }
        if (filters.maxUserRating != null) {
          final filter =
              FieldFilter('rating', '<=', filters.maxUserRating!.toInt() * 10);
          igdbFilters.add(filter);
        }
        if (filters.minUserRatingCount != null) {
          final filter =
              FieldFilter('rating_count', '>=', filters.minUserRatingCount);
          igdbFilters.add(filter);
        }

        // Aggregated Critic Rating
        if (filters.minAggregatedRating != null) {
          final filter = FieldFilter(
            'aggregated_rating',
            '>=',
            filters.minAggregatedRating!.toInt() * 10,
          );
          igdbFilters.add(filter);
        }
        if (filters.maxAggregatedRating != null) {
          final filter = FieldFilter(
            'aggregated_rating',
            '<=',
            filters.maxAggregatedRating!.toInt() * 10,
          );
          igdbFilters.add(filter);
        }
        if (filters.minAggregatedRatingCount != null) {
          final filter = FieldFilter(
            'aggregated_rating_count',
            '>=',
            filters.minAggregatedRatingCount,
          );
          igdbFilters.add(filter);
        }

        // ========== GAME TYPE & STATUS FILTERS ==========
        if (filters.gameTypeIds.isNotEmpty) {
          final filter = ContainsFilter('game_type', filters.gameTypeIds);
          igdbFilters.add(filter);
        }
        if (filters.gameStatusIds.isNotEmpty) {
          final filter = ContainsFilter('game_status', filters.gameStatusIds);
          igdbFilters.add(filter);
        }

        // ========== MODES & PERSPECTIVES ==========
        if (filters.themesIds.isNotEmpty) {
          final filter = ContainsFilter('themes', filters.themesIds);
          igdbFilters.add(filter);
        }
        if (filters.gameModesIds.isNotEmpty) {
          final filter = ContainsFilter('game_modes', filters.gameModesIds);
          igdbFilters.add(filter);
        }
        if (filters.playerPerspectiveIds.isNotEmpty) {
          final filter = ContainsFilter(
            'player_perspectives',
            filters.playerPerspectiveIds,
          );
          igdbFilters.add(filter);
        }
        if (filters.multiplayerModeIds.isNotEmpty) {
          final filter =
              ContainsFilter('multiplayer_modes', filters.multiplayerModeIds);
          igdbFilters.add(filter);
        }

        // Multiplayer/Singleplayer boolean checks
        if (filters.hasMultiplayer != null) {
          if (filters.hasMultiplayer!) {
            const filter = NullFilter('multiplayer_modes', isNull: false);
            igdbFilters.add(filter);
          }
        }
        if (filters.hasSinglePlayer != null) {
          if (filters.hasSinglePlayer!) {
            // Check if game_modes contains singleplayer (ID: 1)
            const filter = ContainsFilter('game_modes', [1]);
            igdbFilters.add(filter);
          }
        }

        // ========== POPULARITY & HYPE ==========
        if (filters.minHypes != null) {
          final filter = FieldFilter('hypes', '>=', filters.minHypes);
          igdbFilters.add(filter);
        }

        // ========== AGE RATING & LOCALIZATION ==========
        if (filters.ageRatingCategoryIds.isNotEmpty) {
          final filter = ContainsFilter(
            'age_ratings.rating_category',
            filters.ageRatingCategoryIds,
          );
          igdbFilters.add(filter);
        }
        if (filters.languageSupportIds.isNotEmpty) {
          final filter =
              ContainsFilter('language_supports', filters.languageSupportIds);
          igdbFilters.add(filter);
        }

        // ========== DYNAMIC SEARCH FILTERS ==========
        if (filters.companyIds.isNotEmpty) {
          final companyFilter =
              ContainsFilter('involved_companies.company', filters.companyIds);

          // Add developer/publisher specific filters if specified
          final companyFilters = <IgdbFilter>[companyFilter];

          if (filters.isDeveloper ?? false) {
            companyFilters.add(
              const FieldFilter('involved_companies.developer', '=', true),
            );
          }

          if (filters.isPublisher ?? false) {
            companyFilters.add(
              const FieldFilter('involved_companies.publisher', '=', true),
            );
          }

          // Combine company filters with AND logic
          if (companyFilters.length > 1) {
            igdbFilters.add(CombinedFilter(companyFilters));
          } else {
            igdbFilters.add(companyFilter);
          }
        }
        if (filters.gameEngineIds.isNotEmpty) {
          final filter = ContainsFilter('game_engines', filters.gameEngineIds);
          igdbFilters.add(filter);
        }
        if (filters.franchiseIds.isNotEmpty) {
          final filter = ContainsFilter('franchises', filters.franchiseIds);
          igdbFilters.add(filter);
        }
        if (filters.collectionIds.isNotEmpty) {
          final filter = ContainsFilter('collections', filters.collectionIds);
          igdbFilters.add(filter);
        }
        if (filters.keywordIds.isNotEmpty) {
          final filter = ContainsFilter('keywords', filters.keywordIds);
          igdbFilters.add(filter);
        }

        final whereClause =
            igdbFilters.isNotEmpty ? CombinedFilter(igdbFilters) : null;

        if (whereClause != null) {}

        // Build sort string from filters
        // Note: 'relevance' sort only works with text search
        String sortString;
        if (filters.sortBy == GameSortBy.relevance &&
            (textQuery == null || textQuery.trim().isEmpty)) {
          // Fall back to total_rating_count when relevance is selected without search
          sortString = 'total_rating_count ${filters.sortOrder.value}';
        } else {
          sortString = '${filters.sortBy.igdbField} ${filters.sortOrder.value}';
        }

        final query = IgdbGameQuery(
          where: whereClause,
          fields: GameFieldSets.standard,
          limit: limit,
          offset: offset,
          sort: sortString,
        );

        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to perform advanced game search',
    );
  }
}
