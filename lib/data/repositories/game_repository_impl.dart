// lib/data/repositories/game_repository_impl.dart

/// Refactored Game Repository Implementation.
///
/// Uses [IgdbBaseRepository] for unified error handling and the new
/// IGDB query system for clean, maintainable code.
///
/// Key improvements:
/// - Extends IgdbBaseRepository for automatic error handling
/// - Uses GameQueryPresets for common queries
/// - Eliminates ~70% code duplication
/// - Better separation of concerns
/// - GameEnrichmentService for user data
/// - Production-ready error handling
library;

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/domain/entities/ageRating/age_rating_category.dart';
import 'package:gamer_grove/domain/entities/artwork.dart';
import 'package:gamer_grove/domain/entities/character/character_gender.dart';
import 'package:gamer_grove/domain/entities/character/character_species.dart';
import 'package:gamer_grove/domain/entities/collection/collection.dart';
import 'package:gamer_grove/domain/entities/franchise.dart';
import 'package:gamer_grove/domain/entities/game/game_mode.dart';
import 'package:gamer_grove/domain/entities/game/game_status.dart';
import 'package:gamer_grove/domain/entities/game/game_type.dart';
import 'package:gamer_grove/domain/entities/keyword.dart';
import 'package:gamer_grove/domain/entities/language/language.dart';
import 'package:gamer_grove/domain/entities/player_perspective.dart';
import 'package:gamer_grove/domain/entities/screenshot.dart';
import 'package:gamer_grove/domain/entities/search/search_filters.dart';
import 'package:gamer_grove/domain/entities/theme.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_filters.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_sort_options.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_summary.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/services/game_enrichment_service.dart';
import '../../domain/entities/game/game.dart';
import '../../domain/entities/game/game_sort_options.dart';
import '../../domain/entities/website/website.dart';
import '../../domain/entities/ageRating/age_rating.dart';
import '../../domain/entities/character/character.dart';
import '../../domain/entities/event/event.dart';
import '../../domain/entities/platform/platform.dart';
import '../../domain/entities/company/company.dart';
import '../../domain/entities/game/game_engine.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/game/game_video.dart';
import '../../domain/entities/game/game_media_collection.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/remote/igdb/igdb_datasource.dart';
import '../datasources/remote/igdb/models/igdb_query.dart';
import '../datasources/remote/igdb/models/igdb_filters.dart' hide GameFilters;
import '../datasources/remote/igdb/models/game/game_query_presets.dart';
import '../datasources/remote/igdb/models/game/game_filters.dart';
import '../datasources/remote/igdb/models/game/game_field_sets.dart';
import '../datasources/remote/igdb/models/character/character_query_presets.dart';
import '../datasources/remote/igdb/models/event/event_query_presets.dart';
import '../datasources/remote/igdb/models/platform/platform_query_presets.dart';
import '../datasources/remote/igdb/models/company/company_query_presets.dart';
import '../datasources/remote/igdb/models/game_engine/game_engine_query_presets.dart';
import '../datasources/remote/supabase/supabase_user_datasource.dart';
import 'base/igdb_base_repository.dart';

/// Concrete implementation of [GameRepository].
///
/// Handles all game-related operations using the IGDB API through
/// the unified query system.
///
/// Example usage:
/// ```dart
/// final gameRepo = GameRepositoryImpl(
///   igdbDataSource: igdbDataSource,
///   enrichmentService: enrichmentService,
///   networkInfo: networkInfo,
/// );
///
/// // Search games
/// final result = await gameRepo.searchGames('witcher', 20, 0);
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (games) => print('Found ${games.length} games'),
/// );
/// ```
class GameRepositoryImpl extends IgdbBaseRepository implements GameRepository {
  final IgdbDataSource igdbDataSource;
  final SupabaseUserDataSource? supabaseUserDataSource;
  final GameEnrichmentService? enrichmentService;

  GameRepositoryImpl({
    required this.igdbDataSource,
    required NetworkInfo networkInfo,
    this.supabaseUserDataSource,
    this.enrichmentService,
  }) : super(networkInfo: networkInfo);

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
        print('Executing search query: $searchQuery');
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

        // Handle the Either result from getGameCharacters
        charactersResult.fold(
          (failure) => game.characters = [],
          (characters) => game.characters = characters,
        );

        eventResult.fold(
          (failure) => game.events = [],
          (events) => game.events = events,
        );

        return game;
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
        (failure) => Left(failure),
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
          offset: 0,
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
          offset: 0,
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
    print(
        '🎮 GameRepository: getPopularGames called (limit: $limit, offset: $offset)');
    return executeIgdbOperation(
      operation: () async {
        print('🎮 GameRepository: Creating popular games query');
        final query = GameQueryPresets.popular(
          limit: limit,
          offset: offset,
        );
        print('🎮 GameRepository: Executing popular games query: $query');
        print('🎮 GameRepository: Calling IGDB DataSource');
        final result = await igdbDataSource.queryGames(query);
        print(
            '🎮 GameRepository: Received ${result.length} games from DataSource');
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
          minRating: 80.0,
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
          fields: ['similar_games'],
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
          limit: 20,
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
          offset: 0,
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
          offset: 0,
          sort: 'first_release_date desc',
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch game expansions',
    );
  }

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
    String? textQuery,
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  }) {
    return executeIgdbOperation(
      operation: () async {
        print('\n' + '=' * 80);
        print('🔍 ADVANCED GAME SEARCH - FILTER DEBUG');
        print('=' * 80);
        print('📝 Text Query: ${textQuery ?? "NONE"}');
        print('🎯 Filters Applied:');

        // Build combined filters from SearchFilters
        final igdbFilters = <IgdbFilter>[
          //GameFilters.mainGamesOnly(),
        ];

        // Add text search if provided
        if (textQuery != null && textQuery.trim().isNotEmpty) {
          final nameFilter = GameFilters.searchByName(textQuery.trim());
          print('  ✓ Name Filter: ${nameFilter.toQueryString()}');
          igdbFilters.add(nameFilter);
        }

        // ========== BASIC FILTERS ==========
        // Genre filters
        if (filters.genreIds.isNotEmpty) {
          final genreFilter = ContainsFilter('genres', filters.genreIds);
          print('  ✓ Genre Filter: ${genreFilter.toQueryString()}');
          igdbFilters.add(genreFilter);
        }

        // Platform filters
        if (filters.platformIds.isNotEmpty) {
          final platformFilter =
              ContainsFilter('platforms', filters.platformIds);
          print('  ✓ Platform Filter: ${platformFilter.toQueryString()}');
          igdbFilters.add(platformFilter);
        }

        // Release date filters
        if (filters.releaseDateFrom != null) {
          final dateFilter =
              GameFilters.releasedAfter(filters.releaseDateFrom!);
          print('  ✓ Release Date From: ${dateFilter.toQueryString()}');
          igdbFilters.add(dateFilter);
        }
        if (filters.releaseDateTo != null) {
          final dateFilter = GameFilters.releasedBefore(filters.releaseDateTo!);
          print('  ✓ Release Date To: ${dateFilter.toQueryString()}');
          igdbFilters.add(dateFilter);
        }

        // ========== RATING FILTERS ==========
        // Total Rating (user + critic combined)
        if (filters.minTotalRating != null) {
          final filter = FieldFilter(
              'total_rating', '>=', filters.minTotalRating!.toInt() * 10);
          print('  ✓ Min Total Rating: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.maxTotalRating != null) {
          final filter = FieldFilter(
              'total_rating', '<=', filters.maxTotalRating!.toInt() * 10);
          print('  ✓ Max Total Rating: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.minTotalRatingCount != null) {
          final filter = FieldFilter(
              'total_rating_count', '>=', filters.minTotalRatingCount);
          print('  ✓ Min Total Rating Count: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }

        // IGDB User Rating
        if (filters.minUserRating != null) {
          final filter =
              FieldFilter('rating', '>=', filters.minUserRating!.toInt() * 10);
          print('  ✓ Min User Rating: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.maxUserRating != null) {
          final filter =
              FieldFilter('rating', '<=', filters.maxUserRating!.toInt() * 10);
          print('  ✓ Max User Rating: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.minUserRatingCount != null) {
          final filter =
              FieldFilter('rating_count', '>=', filters.minUserRatingCount);
          print('  ✓ Min User Rating Count: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }

        // Aggregated Critic Rating
        if (filters.minAggregatedRating != null) {
          final filter = FieldFilter('aggregated_rating', '>=',
              filters.minAggregatedRating!.toInt() * 10);
          print('  ✓ Min Aggregated Rating: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.maxAggregatedRating != null) {
          final filter = FieldFilter('aggregated_rating', '<=',
              filters.maxAggregatedRating!.toInt() * 10);
          print('  ✓ Max Aggregated Rating: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.minAggregatedRatingCount != null) {
          final filter = FieldFilter('aggregated_rating_count', '>=',
              filters.minAggregatedRatingCount);
          print('  ✓ Min Aggregated Rating Count: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }

        // ========== GAME TYPE & STATUS FILTERS ==========
        if (filters.gameTypeIds.isNotEmpty) {
          final filter = ContainsFilter('game_type', filters.gameTypeIds);
          print('  ✓ Game Type Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.gameStatusIds.isNotEmpty) {
          final filter = ContainsFilter('game_status', filters.gameStatusIds);
          print('  ✓ Game Status Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }

        // ========== MODES & PERSPECTIVES ==========
        if (filters.themesIds.isNotEmpty) {
          final filter = ContainsFilter('themes', filters.themesIds);
          print('  ✓ Themes Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.gameModesIds.isNotEmpty) {
          final filter = ContainsFilter('game_modes', filters.gameModesIds);
          print('  ✓ Game Modes Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.playerPerspectiveIds.isNotEmpty) {
          final filter = ContainsFilter(
              'player_perspectives', filters.playerPerspectiveIds);
          print('  ✓ Player Perspectives Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.multiplayerModeIds.isNotEmpty) {
          final filter =
              ContainsFilter('multiplayer_modes', filters.multiplayerModeIds);
          print('  ✓ Multiplayer Modes Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }

        // Multiplayer/Singleplayer boolean checks
        if (filters.hasMultiplayer != null) {
          if (filters.hasMultiplayer!) {
            final filter = NullFilter('multiplayer_modes', isNull: false);
            print('  ✓ Has Multiplayer: ${filter.toQueryString()}');
            igdbFilters.add(filter);
          }
        }
        if (filters.hasSinglePlayer != null) {
          if (filters.hasSinglePlayer!) {
            // Check if game_modes contains singleplayer (ID: 1)
            final filter = ContainsFilter('game_modes', [1]);
            print('  ✓ Has Singleplayer: ${filter.toQueryString()}');
            igdbFilters.add(filter);
          }
        }

        // ========== POPULARITY & HYPE ==========
        if (filters.minHypes != null) {
          final filter = FieldFilter('hypes', '>=', filters.minHypes!);
          print('  ✓ Min Hypes: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }

        // ========== AGE RATING & LOCALIZATION ==========
        if (filters.ageRatingCategoryIds.isNotEmpty) {
          final filter = ContainsFilter(
              'age_ratings.rating_category', filters.ageRatingCategoryIds);
          print('  ✓ Age Ratings Category Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.languageSupportIds.isNotEmpty) {
          final filter =
              ContainsFilter('language_supports', filters.languageSupportIds);
          print('  ✓ Language Supports Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }

        // ========== DYNAMIC SEARCH FILTERS ==========
        if (filters.companyIds.isNotEmpty) {
          final companyFilter =
              ContainsFilter('involved_companies.company', filters.companyIds);
          print('  ✓ Companies Filter: ${companyFilter.toQueryString()}');

          // Add developer/publisher specific filters if specified
          final List<IgdbFilter> companyFilters = [companyFilter];

          if (filters.isDeveloper == true) {
            companyFilters.add(
              FieldFilter('involved_companies.developer', '=', true)
            );
            print('  ✓ Developer Filter: involved_companies.developer = true');
          }

          if (filters.isPublisher == true) {
            companyFilters.add(
              FieldFilter('involved_companies.publisher', '=', true)
            );
            print('  ✓ Publisher Filter: involved_companies.publisher = true');
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
          print('  ✓ Game Engines Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.franchiseIds.isNotEmpty) {
          final filter = ContainsFilter('franchises', filters.franchiseIds);
          print('  ✓ Franchises Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.collectionIds.isNotEmpty) {
          final filter = ContainsFilter('collections', filters.collectionIds);
          print('  ✓ Collections Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }
        if (filters.keywordIds.isNotEmpty) {
          final filter = ContainsFilter('keywords', filters.keywordIds);
          print('  ✓ Keywords Filter: ${filter.toQueryString()}');
          igdbFilters.add(filter);
        }

        print('\n📊 Total Filters Applied: ${igdbFilters.length}');

        final whereClause =
            igdbFilters.isNotEmpty ? CombinedFilter(igdbFilters) : null;

        if (whereClause != null) {
          print('🔗 Combined WHERE Clause:');
          print('   ${whereClause.toQueryString()}');
        }

        // Build sort string from filters
        // Note: 'relevance' sort only works with text search
        String sortString;
        if (filters.sortBy == GameSortBy.relevance &&
            (textQuery == null || textQuery.trim().isEmpty)) {
          // Fall back to total_rating_count when relevance is selected without search
          sortString = 'total_rating_count ${filters.sortOrder.value}';
          print(
              '⚠️ Relevance sort requires text search - falling back to total_rating_count');
        } else {
          sortString = '${filters.sortBy.igdbField} ${filters.sortOrder.value}';
        }
        print('📊 Sort: $sortString');

        final query = IgdbGameQuery(
          where: whereClause,
          fields: GameFieldSets.standard,
          limit: limit,
          offset: offset,
          sort: sortString,
        );

        print('\n📋 Final Query String:');
        print(query.buildQuery());
        print('=' * 80 + '\n');

        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to perform advanced game search',
    );
  }

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
    print('\n' + '=' * 80);
    print('🎭 LOADING GENRES');
    print('=' * 80);
    return executeIgdbOperation(
      operation: () async {
        // Query all genres from IGDB
        final query = IgdbGenreQuery(
          fields: [
            '*',
          ],
          limit: 100,
          offset: 0,
          sort: 'name asc',
        );
        print('📋 Query: ${query.buildQuery()}');
        final result = await igdbDataSource.queryGenres(query);
        print('✅ Loaded ${result.length} genres');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to fetch genres',
    );
  }

  @override
  Future<Either<Failure, List<Platform>>> getAllPlatforms() {
    print('\n' + '=' * 80);
    print('🎮 LOADING PLATFORMS');
    print('=' * 80);
    return executeIgdbOperation(
      operation: () async {
        final query = PlatformQueryPresets.basicList(
          limit: 200,
          offset: 0,
          sort: 'name asc',
        );
        print('📋 Query: ${query.buildQuery()}');
        final result = await igdbDataSource.queryPlatforms(query);
        print('✅ Loaded ${result.length} platforms');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to fetch platforms',
    );
  }

  @override
  Future<Either<Failure, List<Genre>>> searchGenres(String query) {
    print('\n' + '=' * 80);
    print('🔍 SEARCHING GENRES');
    print('=' * 80);
    print('Search term: $query');
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbGenreQuery(
          where: filter,
          fields: const [
            '*',
          ],
          limit: 50,
          offset: 0,
          sort: 'name asc',
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryGenres(igdbQuery);
        print('✅ Found ${result.length} genres');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to search genres',
    );
  }

  @override
  Future<Either<Failure, List<Platform>>> searchPlatforms(String query) {
    print('\n' + '=' * 80);
    print('🔍 SEARCHING PLATFORMS');
    print('=' * 80);
    print('Search term: $query');
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = PlatformQueryPresets.basicList(
          filter: filter,
          limit: 50,
          offset: 0,
          sort: 'name asc',
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryPlatforms(igdbQuery);
        print('✅ Found ${result.length} platforms');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to search platforms',
    );
  }

  @override
  Future<Either<Failure, List<GameEngine>>> searchGameEngines(String query) {
    print('\n' + '=' * 80);
    print('🔍 SEARCHING GAME ENGINES');
    print('=' * 80);
    print('Search term: $query');
    return executeIgdbOperation(
      operation: () async {
        final igdbQuery = GameEngineQueryPresets.search(
          searchTerm: query,
          limit: 20,
          offset: 0,
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryGameEngines(igdbQuery);
        print('✅ Found ${result.length} game engines');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to search game engines',
    );
  }

  @override
  Future<Either<Failure, List<Franchise>>> searchFranchises(String query) {
    print('\n' + '=' * 80);
    print('🔍 SEARCHING FRANCHISES');
    print('=' * 80);
    print('Search term: $query');
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbFranchiseQuery(
          where: filter,
          fields: const [
            '*',
          ],
          limit: 20,
          sort: 'name asc',
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryFranchises(igdbQuery);
        print('✅ Found ${result.length} franchises');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to search franchises',
    );
  }

  @override
  Future<Either<Failure, List<Collection>>> searchCollections(String query) {
    print('\n' + '=' * 80);
    print('🔍 SEARCHING COLLECTIONS');
    print('=' * 80);
    print('Search term: $query');
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbCollectionQuery(
          where: filter,
          fields: const [
            '*',
          ],
          limit: 20,
          sort: 'name asc',
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryCollections(igdbQuery);
        print('✅ Found ${result.length} collections');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to search collections',
    );
  }

  @override
  Future<Either<Failure, List<Keyword>>> searchKeywords(String query) {
    print('\n' + '=' * 80);
    print('🔍 SEARCHING KEYWORDS');
    print('=' * 80);
    print('Search term: $query');
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbKeywordQuery(
          where: filter,
          fields: const [
            '*',
          ],
          limit: 20,
          sort: 'name asc',
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryKeywords(igdbQuery);
        print('✅ Found ${result.length} keywords');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to search keywords',
    );
  }

  @override
  Future<Either<Failure, List<AgeRatingCategory>>> getAllAgeRatings() {
    print('\n' + '=' * 80);
    print('🔞 LOADING AGE RATINGS');
    print('=' * 80);
    return executeIgdbOperation(
      operation: () async {
        final igdbQuery = IgdbAgeRatingQuery(
          fields: const ['*', 'rating_category.*', 'organization.*'],
          limit: 100,
          sort: 'organization asc',
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryAgeRatings(igdbQuery);
        print('✅ Found ${result.length} age ratings');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to get age ratings',
    );
  }

  @override
  Future<Either<Failure, List<Language>>> searchLanguages(
    String query,
  ) {
    print('\n' + '=' * 80);
    print('🔍 SEARCHING LANGUAGES');
    print('=' * 80);
    print('Search term: $query');
    return executeIgdbOperation(
      operation: () async {
        final multiFieldFilter = CombinedFilter([
          FieldFilter('name', '~', query),
          FieldFilter('native_name', '~', query),
        ], operator: '|'); // Use OR operator to match ANY field

        final igdbQuery = IgdbLanguageQuery(
          where: multiFieldFilter,
          fields: const [
            '*',
          ],
          limit: 20,
          sort: 'name asc',
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryLanguages(igdbQuery);
        print('✅ Found ${result.length} languages');
        print('=' * 80 + '\n');
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
          offset: 0,
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
          offset: 0,
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
    print('\n' + '=' * 80);
    print('🏢 LOADING COMPANIES');
    print('=' * 80);
    print('Search term: ${search ?? "NONE"}');
    print('IDs: ${ids ?? "NONE"}');
    return executeIgdbOperation(
      operation: () async {
        IgdbCompanyQuery query;

        if (ids != null && ids.isNotEmpty) {
          // Query by IDs
          final filter = ContainsFilter('id', ids);
          query = CompanyQueryPresets.basicList(
            filter: filter,
            limit: ids.length,
            offset: 0,
          );
        } else if (search != null && search.trim().isNotEmpty) {
          // Query by search term
          query = CompanyQueryPresets.search(
            searchTerm: search.trim(),
            limit: 20,
            offset: 0,
          );
        } else {
          // Return all companies (limited)
          query = CompanyQueryPresets.basicList(
            limit: 100,
            offset: 0,
          );
        }

        print('📋 Query: ${query.buildQuery()}');
        final result = await igdbDataSource.queryCompanies(query);
        print('✅ Loaded ${result.length} companies');
        print('=' * 80 + '\n');
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
      (failure) => Left(failure),
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
          fields: ['games'],
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
          offset: 0,
        );
        return igdbDataSource.queryGames(gameQuery);
      },
      errorMessage: 'Failed to fetch event games',
    );
  }

  @override
  Future<Either<Failure, List<Game>>> getFilteredGames({
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  }) {
    // Reuse advancedGameSearch without text query
    return advancedGameSearch(
      textQuery: null,
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
          fields: ['age_ratings.*'],
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
          fields: ['artworks.*'],
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
          limit: 50,
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
          fields: ['artworks.*', 'screenshots.*', 'videos.*'],
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
          fields: ['screenshots.*'],
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
          fields: ['videos.*'],
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
          fields: ['websites.*'],
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
          fields: ['games'],
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
        final startDate = DateTime(fromYear, 1, 1);
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
          daysAgo: 30, // Last 30 days
        );
        return igdbDataSource.queryGames(query);
      },
      errorMessage: 'Failed to fetch newest games',
    );
  }

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
          offset: 0,
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
          limit: 20,
          offset: 0,
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
          limit: 20,
          offset: 0,
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
    print('\n' + '=' * 80);
    print('🎭 LOADING GAME MODES');
    print('=' * 80);
    return executeIgdbOperation(
      operation: () async {
        // Query all game modes from IGDB
        final query = IgdbGameModeQuery(
          fields: [
            '*',
          ],
          limit: 100,
          offset: 0,
          sort: 'name asc',
        );
        print('📋 Query: ${query.buildQuery()}');
        final result = await igdbDataSource.queryGameModes(query);
        print('✅ Loaded ${result.length} game modes');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to fetch game modes',
    );
  }

  @override
  Future<Either<Failure, List<GameStatus>>> getAllGameStatuses() {
    print('\n' + '=' * 80);
    print('🎭 LOADING GAME STATUSES');
    print('=' * 80);
    return executeIgdbOperation(
      operation: () async {
        // Query all game statuses from IGDB
        final query = IgdbGameStatusQuery(
          fields: [
            '*',
          ],
          limit: 100,
          offset: 0,
          sort: 'name asc',
        );
        print('📋 Query: ${query.buildQuery()}');
        final result = await igdbDataSource.queryGameStatuses(query);
        print('✅ Loaded ${result.length} game statuses');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to fetch game statuses',
    );
  }

  @override
  Future<Either<Failure, List<GameType>>> getAllGameTypes() {
    print('\n' + '=' * 80);
    print('🎭 LOADING GAME TYPES');
    print('=' * 80);
    return executeIgdbOperation(
      operation: () async {
        // Query all game types from IGDB
        final query = IgdbGameTypeQuery(
          fields: [
            '*',
          ],
          limit: 100,
          offset: 0,
          sort: 'name asc',
        );
        print('📋 Query: ${query.buildQuery()}');
        final result = await igdbDataSource.queryGameTypes(query);
        print('✅ Loaded ${result.length} game types');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to fetch game types',
    );
  }

  @override
  Future<Either<Failure, List<PlayerPerspective>>> getAllPlayerPerspectives() {
    print('\n' + '=' * 80);
    print('🎭 LOADING PLAYER PERSPECTIVES');
    print('=' * 80);
    return executeIgdbOperation(
      operation: () async {
        // Query all player perspectives from IGDB
        final query = IgdbPlayerPerspectiveQuery(
          fields: [
            '*',
          ],
          limit: 100,
          offset: 0,
          sort: 'name asc',
        );
        print('📋 Query: ${query.buildQuery()}');
        final result = await igdbDataSource.queryPlayerPerspectives(query);
        print('✅ Loaded ${result.length} player perspectives');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to fetch player perspectives',
    );
  }

  @override
  Future<Either<Failure, List<AgeRatingCategory>>> searchAgeRatings(
      String query) {
    print('\n' + '=' * 80);
    print('🔍 SEARCHING AGE RATINGS');
    print('=' * 80);
    print('Search term: $query');
    return executeIgdbOperation(
      operation: () async {
        // Create multiple filters for different fields (OR logic)
        // Search in: organization name, rating category, and content descriptions
        final multiFieldFilter = CombinedFilter([
          FieldFilter('organization.name', '~', query),
          FieldFilter('rating', '~', query),
        ], operator: '|'); // Use OR operator to match ANY field

        final igdbQuery = IgdbAgeRatingQuery(
          where: multiFieldFilter,
          fields: const [
            '*',
            'organization.*',
          ],
          limit: 20,
          sort: 'organization.name asc',
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryAgeRatings(igdbQuery);
        print('✅ Found ${result.length} age ratings');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to search age ratings',
    );
  }

  @override
  Future<Either<Failure, List<IGDBTheme>>> searchThemes(String query) {
    print('\n' + '=' * 80);
    print('🔍 SEARCHING THEMES');
    print('=' * 80);
    print('Search term: $query');
    return executeIgdbOperation(
      operation: () async {
        final filter = FieldFilter('name', '~', query);
        final igdbQuery = IgdbThemeQuery(
          where: filter,
          fields: const [
            '*',
          ],
          limit: 20,
          sort: 'name asc',
        );
        print('📋 Query: ${igdbQuery.buildQuery()}');
        final result = await igdbDataSource.queryThemes(igdbQuery);
        print('✅ Found ${result.length} themes');
        print('=' * 80 + '\n');
        return result;
      },
      errorMessage: 'Failed to search themes',
    );
  }
}
