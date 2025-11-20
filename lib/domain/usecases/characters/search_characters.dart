// ==========================================

// lib/domain/usecases/characters/search_characters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class SearchCharacters extends UseCase<List<Character>, SearchCharactersParams> {

  SearchCharacters(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Character>>> call(SearchCharactersParams params) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    return repository.searchCharacters(params.query.trim());
  }
}

class SearchCharactersParams extends Equatable {

  const SearchCharactersParams({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}

