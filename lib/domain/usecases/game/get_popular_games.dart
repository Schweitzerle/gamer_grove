// domain/usecases/game/get_popular_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetPopularGames extends UseCase<List<Game>, GetPopularGamesParams> {
  final GameRepository repository;

  GetPopularGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetPopularGamesParams params) async {
    return await repository.getPopularGames(
      params.limit,
      params.offset,
    );
  }
}

class GetPopularGamesParams extends Equatable {
  final int limit;
  final int offset;

  const GetPopularGamesParams({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}

