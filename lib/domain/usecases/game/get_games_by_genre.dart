// ==========================================

// lib/domain/usecases/game/get_games_by_genre.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/game/game_sort_options.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGamesByGenre extends UseCase<List<Game>, GetGamesByGenreParams> {
  final GameRepository repository;

  GetGamesByGenre(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetGamesByGenreParams params) async {
    if (params.genreIds.isEmpty) {
      return const Left(ValidationFailure(message: 'At least one genre ID required'));
    }

    return await repository.getGamesByGenre(
      genreIds: params.genreIds,
      limit: params.limit,
      offset: params.offset,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class GetGamesByGenreParams extends Equatable {
  final List<int> genreIds;
  final int limit;
  final int offset;
  final GameSortBy sortBy;
  final SortOrder sortOrder;

  const GetGamesByGenreParams({
    required this.genreIds,
    this.limit = 20,
    this.offset = 0,
    this.sortBy = GameSortBy.popularity,
    this.sortOrder = SortOrder.descending,
  });

  @override
  List<Object> get props => [genreIds, limit, offset, sortBy, sortOrder];
}

