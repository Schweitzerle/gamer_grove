// ==========================================
// PHASE 4 USE CASES FOR GAME DETAIL ENHANCEMENTS
// ==========================================

// lib/domain/usecases/game_details/get_game_characters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameCharacters extends UseCase<List<Character>, GetGameCharactersParams> {

  GetGameCharacters(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Character>>> call(GetGameCharactersParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return repository.getGameCharacters(params.gameId);
  }
}

class GetGameCharactersParams extends Equatable {

  const GetGameCharactersParams({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

