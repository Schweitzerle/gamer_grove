// ==========================================

// lib/domain/usecases/characters/get_popular_characters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/character/character.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetPopularCharacters extends UseCase<List<Character>, GetPopularCharactersParams> {
  final GameRepository repository;

  GetPopularCharacters(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(GetPopularCharactersParams params) async {
    return await repository.getPopularCharacters(limit: params.limit);
  }
}

class GetPopularCharactersParams extends Equatable {
  final int limit;

  const GetPopularCharactersParams({this.limit = 20});

  @override
  List<Object> get props => [limit];
}


