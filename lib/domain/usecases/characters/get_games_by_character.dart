// ==========================================

// lib/domain/usecases/characters/get_games_by_character.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGamesByCharacter extends UseCase<List<Game>, GetGamesByCharacterParams> {

  GetGamesByCharacter(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetGamesByCharacterParams params) async {
    if (params.characterId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid character ID'));
    }

    return repository.getGamesByCharacter(params.characterId);
  }
}

class GetGamesByCharacterParams extends Equatable {

  const GetGamesByCharacterParams({required this.characterId});
  final int characterId;

  @override
  List<Object> get props => [characterId];
}


