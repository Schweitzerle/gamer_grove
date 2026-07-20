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
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/igdb_datasource.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/character/character_query_presets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/company/company_query_presets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/event/event_query_presets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/game/game_field_sets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/game/game_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/game/game_query_presets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/game_engine/game_engine_query_presets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart'
    hide GameFilters;
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_query.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/platform/platform_query_presets.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/supabase_user_datasource.dart';
import 'package:gamer_grove/data/repositories/base/igdb_base_repository.dart';
import 'package:gamer_grove/domain/entities/ageRating/age_rating.dart';
import 'package:gamer_grove/domain/entities/ageRating/age_rating_category.dart';
import 'package:gamer_grove/domain/entities/artwork.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/character/character_gender.dart';
import 'package:gamer_grove/domain/entities/character/character_species.dart';
import 'package:gamer_grove/domain/entities/collection/collection.dart';
import 'package:gamer_grove/domain/entities/company/company.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/entities/franchise.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import 'package:gamer_grove/domain/entities/game/game_media_collection.dart';
import 'package:gamer_grove/domain/entities/game/game_mode.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';
import 'package:gamer_grove/domain/entities/game/game_status.dart';
import 'package:gamer_grove/domain/entities/game/game_type.dart';
import 'package:gamer_grove/domain/entities/game/game_video.dart';
import 'package:gamer_grove/domain/entities/genre.dart';
import 'package:gamer_grove/domain/entities/keyword.dart';
import 'package:gamer_grove/domain/entities/language/language.dart';
import 'package:gamer_grove/domain/entities/platform/platform.dart';
import 'package:gamer_grove/domain/entities/player_perspective.dart';
import 'package:gamer_grove/domain/entities/screenshot.dart';
import 'package:gamer_grove/domain/entities/search/search_filters.dart';
import 'package:gamer_grove/domain/entities/theme.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_filters.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_sort_options.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_summary.dart';
import 'package:gamer_grove/domain/entities/website/website.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';

part 'game_repository_impl/repo_discovery.dart';
part 'game_repository_impl/repo_by_entity.dart';
part 'game_repository_impl/repo_batch_taxonomy.dart';
part 'game_repository_impl/repo_media_facets.dart';
part 'game_repository_impl/repo_user_stats.dart';
part 'game_repository_impl/repo_user_data.dart';

/// Shared base for [GameRepositoryImpl] and its concern mixins.
///
/// Exposes the collaborators as getter *seams* so the concrete
/// implementation can be split into `part`-file mixins that satisfy
/// the [GameRepository] interface while still reaching the data sources.
abstract class GameRepositoryBase extends IgdbBaseRepository {
  GameRepositoryBase({required super.networkInfo});

  /// IGDB data source for all game-catalog operations.
  IgdbDataSource get igdbDataSource;

  /// Supabase data source for user collection data (nullable seam).
  SupabaseUserDataSource? get supabaseUserDataSource;

  /// Service that enriches IGDB games with user data (nullable seam).
  GameEnrichmentService? get enrichmentService;
}

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
/// );
/// ```
class GameRepositoryImpl extends GameRepositoryBase
    with
        _RepoDiscovery,
        _RepoByEntity,
        _RepoBatchTaxonomy,
        _RepoMediaFacets,
        _RepoUserStats,
        _RepoUserData
    implements GameRepository {
  GameRepositoryImpl({
    required this.igdbDataSource,
    required super.networkInfo,
    this.supabaseUserDataSource,
    this.enrichmentService,
  });

  @override
  final IgdbDataSource igdbDataSource;

  @override
  final SupabaseUserDataSource? supabaseUserDataSource;

  @override
  final GameEnrichmentService? enrichmentService;
}
