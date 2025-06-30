// ==========================================

// lib/domain/usecases/characters/get_character_details.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/character/character.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetCharacterDetails extends UseCase<Character, GetCharacterDetailsParams> {
  final GameRepository repository;

  GetCharacterDetails(this.repository);

  @override
  Future<Either<Failure, Character>> call(GetCharacterDetailsParams params) async {
    if (params.characterId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid character ID'));
    }

    return await repository.getCharacterDetails(params.characterId);
  }
}

class GetCharacterDetailsParams extends Equatable {
  final int characterId;

  const GetCharacterDetailsParams({required this.characterId});

  @override
  List<Object> get props => [characterId];
}

