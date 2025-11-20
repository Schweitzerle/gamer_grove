// lib/domain/usecases/user/remove_from_top_three.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class RemoveFromTopThree extends UseCase<void, RemoveFromTopThreeParams> {

  RemoveFromTopThree(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, void>> call(RemoveFromTopThreeParams params) async {
    // Validation
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    try {
      return await repository.removeFromTopThree(
        userId: params.userId,
        gameId: params.gameId,
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove game from top three: $e'));
    }
  }
}

class RemoveFromTopThreeParams extends Equatable {

  const RemoveFromTopThreeParams({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}
