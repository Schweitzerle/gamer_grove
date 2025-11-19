// lib/data/repositories/character_repository_impl.dart

/// Character Repository Implementation.
///
/// Uses [IgdbBaseRepository] for unified error handling and the new
/// IGDB query system for clean, maintainable code.
library;

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/character/character_gender.dart';
import 'package:gamer_grove/domain/entities/character/character_species.dart';
import 'package:gamer_grove/domain/entities/search/character_search_filters.dart';
import 'package:gamer_grove/domain/repositories/character_repository.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/igdb_datasource.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_query.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/character/character_query_presets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/character/character_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/character/character_field_sets.dart';
import 'base/igdb_base_repository.dart';

/// Concrete implementation of [CharacterRepository].
///
/// Handles all character-related operations using the IGDB API through
/// the unified query system.
class CharacterRepositoryImpl extends IgdbBaseRepository
    implements CharacterRepository {
  final IgdbDataSource igdbDataSource;

  CharacterRepositoryImpl({
    required this.igdbDataSource,
    required super.networkInfo,
  });

  // ============================================================
  // POPULAR CHARACTERS FOR HOME SCREEN
  // ============================================================

  @override
  Future<Either<Failure, List<Character>>> getPopularCharacters({
    int limit = 10,
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

  // ============================================================
  // SEARCH & DETAILS
  // ============================================================

  @override
  Future<Either<Failure, List<Character>>> searchCharacters(String query) {
    if (query.trim().isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final searchQuery = CharacterQueryPresets.search(
          searchTerm: query.trim(),
          limit: 50,
          offset: 0,
        );
        return igdbDataSource.queryCharacters(searchQuery);
      },
      errorMessage: 'Failed to search characters',
    );
  }

  @override
  Future<Either<Failure, List<Character>>> advancedCharacterSearch({
    required CharacterSearchFilters filters,
    String? textQuery,
    int limit = 20,
    int offset = 0,
  }) {
    return executeIgdbOperation(
      operation: () async {
        // Build filters based on CharacterSearchFilters
        final filterList = <IgdbFilter>[];

        // Gender filter
        if (filters.gender != null) {
          filterList.add(CharacterFilters.byGender(filters.gender!));
        }

        // Species filter
        if (filters.species != null) {
          filterList.add(CharacterFilters.bySpecies(filters.species!));
        }

        // Existence filters
        if (filters.hasMugShot == true) {
          filterList.add(CharacterFilters.hasMugShot());
        }
        if (filters.hasDescription == true) {
          filterList.add(CharacterFilters.hasDescription());
        }
        if (filters.hasGames == true) {
          filterList.add(CharacterFilters.hasGames());
        }

        // Text search filter
        if (textQuery != null && textQuery.trim().isNotEmpty) {
          filterList.add(FieldFilter('name', '~', textQuery.trim()));
        }

        // Combine all filters (or null if no filters)
        final combinedFilter = filterList.isEmpty
            ? null
            : (filterList.length == 1
                ? filterList.first
                : CombinedFilter(filterList));

        // Determine sort order (null for relevance = IGDB default order)
        String? sortString;
        if (filters.sortBy != CharacterSortBy.relevance) {
          final String sortField;
          switch (filters.sortBy) {
            case CharacterSortBy.name:
              sortField = 'name';
            case CharacterSortBy.gamesCount:
              // IGDB doesn't support sorting by array count directly
              // Fall back to name sorting
              sortField = 'name';
            case CharacterSortBy.relevance:
              sortField = 'name'; // Won't be reached due to if condition
          }

          final sortOrder = filters.sortOrder == CharacterSortOrder.ascending
              ? 'asc'
              : 'desc';
          sortString = '$sortField $sortOrder';
        }

        final query = IgdbCharacterQuery(
          where: combinedFilter,
          fields: CharacterFieldSets.search,
          limit: limit,
          offset: offset,
          sort: sortString,
        );

        return igdbDataSource.queryCharacters(query);
      },
      errorMessage: 'Failed to perform advanced character search',
    );
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
            characterId: characterId);
        final characters = await igdbDataSource.queryCharacters(query);

        if (characters.isEmpty) {
          throw const IgdbNotFoundException(
            message: 'Character not found',
          );
        }

        return characters.first;
      },
      errorMessage: 'Failed to fetch character details',
    );
  }

  // ============================================================
  // FILTERED QUERIES
  // ============================================================

  @override
  Future<Either<Failure, List<Character>>> getCharactersByGender(
    CharacterGenderEnum gender, {
    int limit = 20,
    int offset = 0,
  }) {
    return executeIgdbOperation(
      operation: () async {
        final query = CharacterQueryPresets.byGender(
          gender: gender,
          limit: limit,
          offset: offset,
        );
        return igdbDataSource.queryCharacters(query);
      },
      errorMessage: 'Failed to fetch characters by gender',
    );
  }

  @override
  Future<Either<Failure, List<Character>>> getCharactersBySpecies(
    CharacterSpeciesEnum species, {
    int limit = 20,
    int offset = 0,
  }) {
    return executeIgdbOperation(
      operation: () async {
        final query = CharacterQueryPresets.bySpecies(
          species: species,
          limit: limit,
          offset: offset,
        );
        return igdbDataSource.queryCharacters(query);
      },
      errorMessage: 'Failed to fetch characters by species',
    );
  }

  @override
  Future<Either<Failure, List<Character>>> getCharactersByGame(int gameId) {
    if (gameId <= 0) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final query = CharacterQueryPresets.fromGame(
          gameId: gameId,
          limit: 50,
          offset: 0,
        );
        return igdbDataSource.queryCharacters(query);
      },
      errorMessage: 'Failed to fetch characters by game',
    );
  }

  @override
  Future<Either<Failure, List<Character>>> getCharactersByGames(
    List<int> gameIds,
  ) {
    if (gameIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final query = CharacterQueryPresets.fromGames(
          gameIds: gameIds,
          limit: 100,
          offset: 0,
        );
        return igdbDataSource.queryCharacters(query);
      },
      errorMessage: 'Failed to fetch characters by games',
    );
  }
}
