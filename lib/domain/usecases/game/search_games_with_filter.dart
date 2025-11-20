// ==========================================
// PHASE 2 USE CASES FOR ENHANCED SEARCH & FILTERING
// ==========================================

// lib/domain/usecases/game/search_games_with_filters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/search/search_filters.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class SearchGamesWithFilters extends UseCase<List<Game>, SearchGamesWithFiltersParams> {

  SearchGamesWithFilters(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(SearchGamesWithFiltersParams params) async {
    if (params.query.isEmpty && !params.filters.hasFilters) {
      return const Left(ValidationFailure(message: 'Search query or filters required'));
    }

    return repository.searchGamesWithFilters(
      query: params.query,
      filters: params.filters,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchGamesWithFiltersParams extends Equatable {

  const SearchGamesWithFiltersParams({
    required this.query,
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });
  final String query;
  final SearchFilters filters;
  final int limit;
  final int offset;

  @override
  List<Object> get props => [query, filters, limit, offset];
}

