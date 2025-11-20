// ==========================================

// lib/domain/usecases/characters/get_character_details.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetCharacterDetails extends UseCase<Character, GetCharacterDetailsParams> {

  GetCharacterDetails(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, Character>> call(GetCharacterDetailsParams params) async {
    if (params.characterId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid character ID'));
    }

    return repository.getCharacterDetails(params.characterId);
  }
}

class GetCharacterDetailsParams extends Equatable {

  const GetCharacterDetailsParams({required this.characterId});
  final int characterId;

  @override
  List<Object> get props => [characterId];
}

