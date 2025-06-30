// ==========================================

// lib/domain/usecases/trends/get_trending_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetTrendingGames extends UseCase<List<Game>, GetTrendingGamesParams> {
  final GameRepository repository;

  GetTrendingGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetTrendingGamesParams params) async {
    return await repository.getTrendingGames(
      limit: params.limit,
      offset: params.offset,
      timeWindow: params.timeWindow,
    );
  }
}

class GetTrendingGamesParams extends Equatable {
  final int limit;
  final int offset;
  final Duration? timeWindow;

  const GetTrendingGamesParams({
    this.limit = 20,
    this.offset = 0,
    this.timeWindow,
  });

  // Predefined time windows for convenience
  GetTrendingGamesParams.lastWeek({this.limit = 20, this.offset = 0})
      : timeWindow = const Duration(days: 7);

  GetTrendingGamesParams.lastMonth({this.limit = 20, this.offset = 0})
      : timeWindow = const Duration(days: 30);

  GetTrendingGamesParams.lastThreeMonths({this.limit = 20, this.offset = 0})
      : timeWindow = const Duration(days: 90);

  @override
  List<Object?> get props => [limit, offset, timeWindow];
}