// domain/usecases/game/rate_game.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class RateGame extends UseCase<void, RateGameParams> {
  final GameRepository repository;

  RateGame(this.repository);

  @override
  Future<Either<Failure, void>> call(RateGameParams params) async {
    if (params.rating < 0 || params.rating > 10) {
      return const Left(ValidationFailure(message: 'Rating must be between 0 and 10'));
    }

    return await repository.rateGame(
      params.gameId,
      params.userId,
      params.rating,
    );
  }
}

class RateGameParams extends Equatable {
  final int gameId;
  final String userId;
  final double rating;

  const RateGameParams({
    required this.gameId,
    required this.userId,
    required this.rating,
  });

  @override
  List<Object> get props => [gameId, userId, rating];
}

