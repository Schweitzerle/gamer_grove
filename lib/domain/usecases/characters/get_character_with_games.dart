// ==================================================
// CHARACTER USE CASE IMPLEMENTATION
// ==================================================

// lib/domain/usecases/characters/get_character_with_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetCharacterWithGames extends UseCase<CharacterWithGames, GetCharacterWithGamesParams> {

  GetCharacterWithGames(this.repository);
  final GameRepository repository;

  // 🆕 USE CASE DEBUGGING ENHANCEMENT
// ==========================================

// Verbessere deine GetCharacterWithGames UseCase:

  @override
  Future<Either<Failure, CharacterWithGames>> call(GetCharacterWithGamesParams params) async {
    try {

      // Get character details (this should include enriched games from repository)
      final characterResult = await repository.getCharacterDetails(params.characterId);

      if (characterResult.isLeft()) {
        return characterResult.fold(
              (failure) {
            return Left(failure);
          },
              (character) => throw Exception('Unexpected success'),
        );
      }

      final character = characterResult.fold(
            (l) => throw Exception('Unexpected failure'),
            (r) => r,
      );


      // The character should already have games loaded from repository
      var games = character.games ?? [];

      if (games.isEmpty && character.gameIds.isNotEmpty && params.includeGames) {

        final gamesResult = await repository.getGamesByIds(character.gameIds);
        if (gamesResult.isRight()) {
          games = gamesResult.fold(
                (failure) {
              return <Game>[];
            },
                (gamesList) {
              return gamesList;
            },
          );
        } else {
        }
      }

      final result = CharacterWithGames(
        character: character,
        games: games,
      );

      return Right(result);

    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load character with games: $e'));
    }
  }
}

class GetCharacterWithGamesParams extends Equatable {

  const GetCharacterWithGamesParams({
    required this.characterId,
    this.includeGames = true,
  });
  final int characterId;
  final bool includeGames;

  @override
  List<Object> get props => [characterId, includeGames];
}

class CharacterWithGames extends Equatable {

  const CharacterWithGames({
    required this.character,
    required this.games,
  });
  final Character character;
  final List<Game> games;

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [character, games];
}
