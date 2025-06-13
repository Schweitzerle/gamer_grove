// domain/usecases/game/get_upcoming_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetUpcomingGames extends UseCase<List<Game>, GetUpcomingGamesParams> {
  final GameRepository repository;

  GetUpcomingGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetUpcomingGamesParams params) async {
    return await repository.getUpcomingGames(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUpcomingGamesParams extends Equatable {
  final int limit;
  final int offset;

  const GetUpcomingGamesParams({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}

