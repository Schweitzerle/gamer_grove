// ==========================================
// PHASE 2 USE CASES FOR ENHANCED SEARCH & FILTERING
// ==========================================

// lib/domain/usecases/game/search_games_with_filters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/search/search_filters.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class SearchGamesWithFilters extends UseCase<List<Game>, SearchGamesWithFiltersParams> {
  final GameRepository repository;

  SearchGamesWithFilters(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(SearchGamesWithFiltersParams params) async {
    if (params.query.isEmpty && !params.filters.hasFilters) {
      return const Left(ValidationFailure(message: 'Search query or filters required'));
    }

    return await repository.searchGamesWithFilters(
      query: params.query,
      filters: params.filters,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchGamesWithFiltersParams extends Equatable {
  final String query;
  final SearchFilters filters;
  final int limit;
  final int offset;

  const SearchGamesWithFiltersParams({
    required this.query,
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [query, filters, limit, offset];
}

