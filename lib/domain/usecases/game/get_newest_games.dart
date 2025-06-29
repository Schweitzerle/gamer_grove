// lib/domain/usecases/game/get_newest_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetNewestGames extends UseCase<List<Game>, GetNewestGamesParams> {
  final GameRepository repository;

  GetNewestGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetNewestGamesParams params) async {
    return await repository.getNewestGames(
      params.limit,
      params.offset,
    );
  }
}

class GetNewestGamesParams extends Equatable {
  final int limit;
  final int offset;

  const GetNewestGamesParams({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}


