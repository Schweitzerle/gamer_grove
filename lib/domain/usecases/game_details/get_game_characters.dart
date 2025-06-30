// ==========================================
// PHASE 4 USE CASES FOR GAME DETAIL ENHANCEMENTS
// ==========================================

// lib/domain/usecases/game_details/get_game_characters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/character/character.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameCharacters extends UseCase<List<Character>, GetGameCharactersParams> {
  final GameRepository repository;

  GetGameCharacters(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(GetGameCharactersParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return await repository.getGameCharacters(params.gameId);
  }
}

class GetGameCharactersParams extends Equatable {
  final int gameId;

  const GetGameCharactersParams({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

