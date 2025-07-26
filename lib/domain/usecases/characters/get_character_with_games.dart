// ==================================================
// CHARACTER USE CASE IMPLEMENTATION
// ==================================================

// lib/domain/usecases/characters/get_character_with_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/character/character.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetCharacterWithGames extends UseCase<CharacterWithGames, GetCharacterWithGamesParams> {
  final GameRepository repository;

  GetCharacterWithGames(this.repository);

  @override
  Future<Either<Failure, CharacterWithGames>> call(GetCharacterWithGamesParams params) async {
    try {
      print('🎭 UseCase: Getting character details for ID: ${params.characterId}');

      // Get character details (this should include enriched games from repository)
      final characterResult = await repository.getCharacterDetails(params.characterId);
      if (characterResult.isLeft()) {
        return characterResult.fold(
              (failure) => Left(failure),
              (character) => throw Exception('Unexpected success'),
        );
      }

      final character = characterResult.fold(
            (l) => throw Exception('Unexpected failure'),
            (r) => r,
      );

      print('✅ UseCase: Character loaded: ${character.name}');
      print('🎮 UseCase: Character has ${character.loadedGameCount} games');

      // The character should already have games loaded from repository
      // But if not, we can load them manually
      List<Game> games = character.games ?? [];

      if (games.isEmpty && character.gameIds.isNotEmpty && params.includeGames) {
        print('⚠️ UseCase: Character has no loaded games, loading manually...');
        final gamesResult = await repository.getGamesByIds(character.gameIds);
        if (gamesResult.isRight()) {
          games = gamesResult.fold(
                (failure) => <Game>[],
                (gamesList) => gamesList,
          );
          print('✅ UseCase: Manually loaded ${games.length} games');
        }
      }

      return Right(CharacterWithGames(
        character: character,
        games: games,
      ));

    } catch (e) {
      print('❌ UseCase: Error loading character: $e');
      return Left(ServerFailure(message: 'Failed to load character with games: $e'));
    }
  }
}

class GetCharacterWithGamesParams extends Equatable {
  final int characterId;
  final bool includeGames;

  const GetCharacterWithGamesParams({
    required this.characterId,
    this.includeGames = true,
  });

  @override
  List<Object> get props => [characterId, includeGames];
}

class CharacterWithGames extends Equatable {
  final Character character;
  final List<Game> games;

  const CharacterWithGames({
    required this.character,
    required this.games,
  });

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [character, games];
}
