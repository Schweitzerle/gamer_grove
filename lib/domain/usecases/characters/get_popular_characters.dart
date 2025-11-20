// ==========================================

// lib/domain/usecases/characters/get_popular_characters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetPopularCharacters extends UseCase<List<Character>, GetPopularCharactersParams> {

  GetPopularCharacters(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Character>>> call(GetPopularCharactersParams params) async {
    return repository.getPopularCharacters(limit: params.limit);
  }
}

class GetPopularCharactersParams extends Equatable {

  const GetPopularCharactersParams({this.limit = 20});
  final int limit;

  @override
  List<Object> get props => [limit];
}


