// lib/domain/repositories/character_repository.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/character/character_gender.dart';
import 'package:gamer_grove/domain/entities/character/character_species.dart';
import 'package:gamer_grove/domain/entities/search/character_search_filters.dart';

abstract class CharacterRepository {
  // Popular Characters for Home Screen
  Future<Either<Failure, List<Character>>> getPopularCharacters({
    int limit = 10,
  });

  // Character Search & Details
  Future<Either<Failure, List<Character>>> searchCharacters(String query);

  Future<Either<Failure, Character>> getCharacterDetails(int characterId);

  // Advanced Character Search with Filters
  Future<Either<Failure, List<Character>>> advancedCharacterSearch({
    required CharacterSearchFilters filters,
    String? textQuery,
    int limit = 20,
    int offset = 0,
  });

  // Characters by Criteria
  Future<Either<Failure, List<Character>>> getCharactersByGender(
    CharacterGenderEnum gender, {
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, List<Character>>> getCharactersBySpecies(
    CharacterSpeciesEnum species, {
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, List<Character>>> getCharactersByGame(int gameId);

  Future<Either<Failure, List<Character>>> getCharactersByGames(
      List<int> gameIds,);
}
