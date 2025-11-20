// domain/usecases/game/rate_game.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class RateGame extends UseCase<void, RateGameParams> {

  RateGame(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, void>> call(RateGameParams params) async {
    if (params.rating < 0 || params.rating > 10) {
      return const Left(ValidationFailure(message: 'Rating must be between 0 and 10'));
    }

    return repository.rateGame(
      params.gameId,
      params.userId,
      params.rating,
    );
  }
}

class RateGameParams extends Equatable {

  const RateGameParams({
    required this.gameId,
    required this.userId,
    required this.rating,
  });
  final int gameId;
  final String userId;
  final double rating;

  @override
  List<Object> get props => [gameId, userId, rating];
}

