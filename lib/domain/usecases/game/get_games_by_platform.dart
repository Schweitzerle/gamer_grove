// ==========================================

// lib/domain/usecases/game/get_games_by_platform.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/game/game_sort_options.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGamesByPlatform extends UseCase<List<Game>, GetGamesByPlatformParams> {
  final GameRepository repository;

  GetGamesByPlatform(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetGamesByPlatformParams params) async {
    if (params.platformIds.isEmpty) {
      return const Left(ValidationFailure(message: 'At least one platform ID required'));
    }

    return await repository.getGamesByPlatform(
      platformIds: params.platformIds,
      limit: params.limit,
      offset: params.offset,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}

class GetGamesByPlatformParams extends Equatable {
  final List<int> platformIds;
  final int limit;
  final int offset;
  final GameSortBy sortBy;
  final SortOrder sortOrder;

  const GetGamesByPlatformParams({
    required this.platformIds,
    this.limit = 20,
    this.offset = 0,
    this.sortBy = GameSortBy.popularity,
    this.sortOrder = SortOrder.descending,
  });

  @override
  List<Object> get props => [platformIds, limit, offset, sortBy, sortOrder];
}

