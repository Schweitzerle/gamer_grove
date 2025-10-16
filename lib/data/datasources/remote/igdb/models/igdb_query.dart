// lib/data/datasources/remote/igdb/models/igdb_query.dart

/// Main query file that exports generic base and defines type aliases
library;

// Export generic base
export 'base/igdb_query.dart';

// Import models for type aliases
import 'package:gamer_grove/data/models/character/character_model.dart';
import 'package:gamer_grove/data/models/game/game_model.dart';
import 'package:gamer_grove/data/models/platform/platform_model.dart';
import 'package:gamer_grove/data/models/company/company_model.dart';
import 'package:gamer_grove/data/models/event/event_model.dart';
import 'package:gamer_grove/data/models/game/game_engine_model.dart';

import 'base/igdb_query.dart';

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
