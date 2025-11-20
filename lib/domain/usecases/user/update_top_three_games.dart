// ==========================================

// lib/domain/usecases/user/update_top_three_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class UpdateTopThreeGames extends UseCase<void, UpdateTopThreeGamesParams> {

  UpdateTopThreeGames(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, void>> call(UpdateTopThreeGamesParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    if (params.gameIds.length != 3) {
      return const Left(ValidationFailure(message: 'Must provide exactly 3 games'));
    }

    // Check for duplicates
    if (params.gameIds.toSet().length != 3) {
      return const Left(ValidationFailure(message: 'All three games must be different'));
    }

    return repository.updateTopThreeGames(
      userId: params.userId,
      gameIds: params.gameIds,
    );
  }
}

class UpdateTopThreeGamesParams extends Equatable {

  const UpdateTopThreeGamesParams({
    required this.userId,
    required this.gameIds,
  });
  final String userId;
  final List<int> gameIds;

  @override
  List<Object> get props => [userId, gameIds];
}
