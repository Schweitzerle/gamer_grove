// ==========================================

// lib/domain/usecases/characters/search_characters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/character/character.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class SearchCharacters extends UseCase<List<Character>, SearchCharactersParams> {
  final GameRepository repository;

  SearchCharacters(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(SearchCharactersParams params) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    return await repository.searchCharacters(params.query.trim());
  }
}

class SearchCharactersParams extends Equatable {
  final String query;

  const SearchCharactersParams({required this.query});

  @override
  List<Object> get props => [query];
}

