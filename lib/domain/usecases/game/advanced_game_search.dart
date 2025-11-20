// ==========================================

// lib/domain/usecases/game/advanced_game_search.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/search/search_filters.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class AdvancedGameSearch extends UseCase<List<Game>, AdvancedGameSearchParams> {

  AdvancedGameSearch(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(AdvancedGameSearchParams params) async {
    if ((params.textQuery?.isEmpty ?? true) && !params.filters.hasFilters) {
      return const Left(ValidationFailure(message: 'Text query or filters required'));
    }

    return repository.advancedGameSearch(
      textQuery: params.textQuery,
      filters: params.filters,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class AdvancedGameSearchParams extends Equatable {

  const AdvancedGameSearchParams({
    required this.filters, this.textQuery,
    this.limit = 20,
    this.offset = 0,
  });
  final String? textQuery;
  final SearchFilters filters;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [textQuery, filters, limit, offset];
}

