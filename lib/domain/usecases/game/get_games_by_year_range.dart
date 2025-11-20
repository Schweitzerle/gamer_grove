// ==========================================

// lib/domain/usecases/game/get_games_by_year_range.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGamesByYearRange extends UseCase<List<Game>, GetGamesByYearRangeParams> {

  GetGamesByYearRange(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetGamesByYearRangeParams params) async {
    if (params.fromYear > params.toYear) {
      return const Left(ValidationFailure(message: 'From year cannot be greater than to year'));
    }

    return repository.getGamesByReleaseYear(
      fromYear: params.fromYear,
      toYear: params.toYear,
      limit: params.limit,
      offset: params.offset,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class GetGamesByYearRangeParams extends Equatable {

  const GetGamesByYearRangeParams({
    required this.fromYear,
    required this.toYear,
    this.limit = 20,
    this.offset = 0,
    this.sortBy = GameSortBy.releaseDate,
    this.sortOrder = SortOrder.descending,
  });
  final int fromYear;
  final int toYear;
  final int limit;
  final int offset;
  final GameSortBy sortBy;
  final SortOrder sortOrder;

  @override
  List<Object> get props => [fromYear, toYear, limit, offset, sortBy, sortOrder];
}

