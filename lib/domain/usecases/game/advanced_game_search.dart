// ==========================================

// lib/domain/usecases/game/advanced_game_search.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/search/search_filters.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class AdvancedGameSearch extends UseCase<List<Game>, AdvancedGameSearchParams> {
  final GameRepository repository;

  AdvancedGameSearch(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(AdvancedGameSearchParams params) async {
    if ((params.textQuery?.isEmpty ?? true) && !params.filters.hasFilters) {
      return const Left(ValidationFailure(message: 'Text query or filters required'));
    }

    return await repository.advancedGameSearch(
      textQuery: params.textQuery,
      filters: params.filters,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class AdvancedGameSearchParams extends Equatable {
  final String? textQuery;
  final SearchFilters filters;
  final int limit;
  final int offset;

  const AdvancedGameSearchParams({
    this.textQuery,
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [textQuery, filters, limit, offset];
}

