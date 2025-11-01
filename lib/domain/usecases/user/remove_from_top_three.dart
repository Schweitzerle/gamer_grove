// lib/domain/usecases/user/remove_from_top_three.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class RemoveFromTopThree extends UseCase<void, RemoveFromTopThreeParams> {
  final UserRepository repository;

  RemoveFromTopThree(this.repository);

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
  final String userId;
  final int gameId;

  const RemoveFromTopThreeParams({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}
