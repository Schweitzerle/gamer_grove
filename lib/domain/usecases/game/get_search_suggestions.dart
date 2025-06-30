// ==========================================

// lib/domain/usecases/game/get_search_suggestions.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetSearchSuggestions extends UseCase<List<String>, GetSearchSuggestionsParams> {
  final GameRepository repository;

  GetSearchSuggestions(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(GetSearchSuggestionsParams params) async {
    if (params.partialQuery.length < 2) {
      return const Right([]);
    }

    return await repository.getSearchSuggestions(params.partialQuery);
  }
}

class GetSearchSuggestionsParams extends Equatable {
  final String partialQuery;

  const GetSearchSuggestionsParams({required this.partialQuery});

  @override
  List<Object> get props => [partialQuery];
}

