// lib/domain/usecases/user/add_to_top_three.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class AddToTopThree extends UseCase<void, AddToTopThreeParams> {

  AddToTopThree(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, void>> call(AddToTopThreeParams params) async {
    // Validation
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    if (params.position < 1 || params.position > 3) {
      return const Left(ValidationFailure(message: 'Position must be 1, 2, or 3'));
    }

    try {
      return await repository.setTopThreeGameAtPosition(
        userId: params.userId,
        position: params.position,
        gameId: params.gameId,
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add game to top three: $e'));
    }
  }
}

class AddToTopThreeParams extends Equatable {

  const AddToTopThreeParams({
    required this.gameId,
    required this.userId,
    required this.position,
  });
  final int gameId;
  final String userId;
  final int position;

  @override
  List<Object?> get props => [gameId, userId, position];
}