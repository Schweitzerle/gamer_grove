// domain/usecases/game/get_latest_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetLatestGames extends UseCase<List<Game>, GetLatestGamesParams> {
  final GameRepository repository;

  GetLatestGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetLatestGamesParams params) async {
    return await repository.getLatestGames(
      params.limit,
      params.offset,
    );
  }
}

class GetLatestGamesParams extends Equatable {
  final int limit;
  final int offset;

  const GetLatestGamesParams({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}

