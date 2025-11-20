// lib/data/datasources/remote/igdb/models/igdb_query.dart

/// Main query file that exports generic base and defines type aliases
library;

import 'package:gamer_grove/data/datasources/remote/igdb/models/base/igdb_query.dart';
// Import models for type aliases
import 'package:gamer_grove/data/models/ageRating/age_rating_category_model.dart';
import 'package:gamer_grove/data/models/character/character_model.dart';
import 'package:gamer_grove/data/models/collection/collection_model.dart';
import 'package:gamer_grove/data/models/company/company_model.dart';
import 'package:gamer_grove/data/models/event/event_model.dart';
import 'package:gamer_grove/data/models/franchise_model.dart';
import 'package:gamer_grove/data/models/game/game_engine_model.dart';
import 'package:gamer_grove/data/models/game/game_mode_model.dart';
import 'package:gamer_grove/data/models/game/game_model.dart';
import 'package:gamer_grove/data/models/game/game_status_model.dart';
import 'package:gamer_grove/data/models/game/game_type_model.dart';
import 'package:gamer_grove/data/models/genre_model.dart';
import 'package:gamer_grove/data/models/keyword_model.dart';
import 'package:gamer_grove/data/models/language/lanuage_model.dart';
import 'package:gamer_grove/data/models/multiplayer_mode_model.dart';
import 'package:gamer_grove/data/models/platform/platform_model.dart';
import 'package:gamer_grove/data/models/player_perspective_model.dart';
import 'package:gamer_grove/data/models/theme_model.dart';

// Export generic base
export 'base/igdb_query.dart';

// ============================================================
// TYPE ALIASES FOR ENTITY-SPECIFIC QUERIES
// ============================================================

/// Query type for games
typedef IgdbGameQuery = IgdbQuery<GameModel>;

/// Query type for characters
typedef IgdbCharacterQuery = IgdbQuery<CharacterModel>;

/// Query type for platforms
typedef IgdbPlatformQuery = IgdbQuery<PlatformModel>;

/// Query type for companies
typedef IgdbCompanyQuery = IgdbQuery<CompanyModel>;

/// Query type for events
typedef IgdbEventQuery = IgdbQuery<EventModel>;

/// Query type for game_engines
typedef IgdbGameEngineQuery = IgdbQuery<GameEngineModel>;

/// Query type for genres
typedef IgdbGenreQuery = IgdbQuery<GenreModel>;

/// Query type for game statuses
typedef IgdbGameStatusQuery = IgdbQuery<GameStatusModel>;

/// Query type for game modes
typedef IgdbGameModeQuery = IgdbQuery<GameModeModel>;

/// Query type for game types
typedef IgdbGameTypeQuery = IgdbQuery<GameTypeModel>;

/// Query type for player perspectives
typedef IgdbPlayerPerspectiveQuery = IgdbQuery<PlayerPerspectiveModel>;

/// Query type for collections
typedef IgdbCollectionQuery = IgdbQuery<CollectionModel>;

/// Query type for franchises
typedef IgdbFranchiseQuery = IgdbQuery<FranchiseModel>;

/// Query type for keywords
typedef IgdbKeywordQuery = IgdbQuery<KeywordModel>;

/// Query type for age ratings
typedef IgdbAgeRatingQuery = IgdbQuery<AgeRatingCategoryModel>;

/// Query type for multiplayer modes
typedef IgdbMultiplayerModeQuery = IgdbQuery<MultiplayerModeModel>;

/// Query type for languages
typedef IgdbLanguageQuery = IgdbQuery<LanguageModel>;

/// Query type for themes
typedef IgdbThemeQuery = IgdbQuery<IGDBThemeModel>;

/// Query type for player

// ============================================================
// BUILDER TYPE ALIASES
// ============================================================

/// Builder type for game queries
typedef IgdbGameQueryBuilder = IgdbQueryBuilder<GameModel>;

/// Builder type for character queries
typedef IgdbCharacterQueryBuilder = IgdbQueryBuilder<CharacterModel>;

/// Builder type for platform queries
typedef IgdbPlatformQueryBuilder = IgdbQueryBuilder<PlatformModel>;

/// Builder type for company queries
typedef IgdbCompanyQueryBuilder = IgdbQueryBuilder<CompanyModel>;

/// Builder type for event queries
typedef IgdbEventQueryBuilder = IgdbQueryBuilder<EventModel>;

/// Builder type for game_engine queries
typedef IgdbGameEngineQueryBuilder = IgdbQueryBuilder<GameEngineModel>;

/// Builder type for genre queries
typedef IgdbGenreQueryBuilder = IgdbQueryBuilder<GenreModel>;
