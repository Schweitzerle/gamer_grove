// ==========================================

// lib/domain/usecases/characters/get_games_by_character.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGamesByCharacter extends UseCase<List<Game>, GetGamesByCharacterParams> {
  final GameRepository repository;

  GetGamesByCharacter(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetGamesByCharacterParams params) async {
    if (params.characterId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid character ID'));
    }

    return await repository.getGamesByCharacter(params.characterId);
  }
}

class GetGamesByCharacterParams extends Equatable {
  final int characterId;

  const GetGamesByCharacterParams({required this.characterId});

  @override
  List<Object> get props => [characterId];
}


