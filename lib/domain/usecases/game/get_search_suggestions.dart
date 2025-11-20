// ==========================================

// lib/domain/usecases/game/get_search_suggestions.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetSearchSuggestions extends UseCase<List<String>, GetSearchSuggestionsParams> {

  GetSearchSuggestions(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<String>>> call(GetSearchSuggestionsParams params) async {
    if (params.partialQuery.length < 2) {
      return const Right([]);
    }

    return repository.getSearchSuggestions(params.partialQuery);
  }
}

class GetSearchSuggestionsParams extends Equatable {

  const GetSearchSuggestionsParams({required this.partialQuery});
  final String partialQuery;

  @override
  List<Object> get props => [partialQuery];
}

