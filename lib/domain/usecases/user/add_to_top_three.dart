// lib/domain/usecases/user/add_to_top_three.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class AddToTopThree extends UseCase<void, AddToTopThreeParams> {
  final UserRepository repository;

  AddToTopThree(this.repository);

  @override
  Future<Either<Failure, void>> call(AddToTopThreeParams params) async {
    // Validation
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    if (params.position != null && (params.position! < 1 || params.position! > 3)) {
      return const Left(ValidationFailure(message: 'Position must be 1, 2, or 3'));
    }

    try {
      // If specific position is provided, use the setTopThreeGameAtPosition method
      if (params.position != null) {
        return await repository.setTopThreeGameAtPosition(
          userId: params.userId,
          position: params.position!,
          gameId: params.gameId,
        );
      }

      // If no position specified, find first available slot
      // Get current top three data as Map<String, dynamic>
      final currentTopThreeResult = await repository.getUserTopThreeGames(
        userId: params.userId,
      );

      return await currentTopThreeResult.fold(
            (failure) => Left(failure),
            (currentTopThreeData) async {
          // Check if game already exists in top three
          bool gameAlreadyExists = false;

          // currentTopThreeData is List<Map<String, dynamic>>
          // Check each entry for the game_id
          for (var entry in currentTopThreeData) {
            if (entry['game_id'] == params.gameId) {
              gameAlreadyExists = true;
              break;
            }
          }

          if (gameAlreadyExists) {
            return const Left(ValidationFailure(
              message: 'Game is already in your top three',
            ));
          }

          // Find first available position (1, 2, or 3)
          // Create a set of occupied positions
          Set<int> occupiedPositions = currentTopThreeData
              .map((entry) => entry['position'] as int)
              .toSet();

          int? availablePosition;
          for (int pos = 1; pos <= 3; pos++) {
            if (!occupiedPositions.contains(pos)) {
              availablePosition = pos;
              break;
            }
          }

          if (availablePosition == null) {
            return const Left(ValidationFailure(
              message: 'Top three is full. Please specify a position to replace.',
            ));
          }

          // Add to the available position
          return await repository.setTopThreeGameAtPosition(
            userId: params.userId,
            position: availablePosition,
            gameId: params.gameId,
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add game to top three: $e'));
    }
  }
}


class AddToTopThreeParams extends Equatable {
  final int gameId;
  final String userId;
  final int? position; // 1, 2, or 3 - if null, finds first available slot

  const AddToTopThreeParams({
    required this.gameId,
    required this.userId,
    this.position,
  });

  @override
  List<Object?> get props => [gameId, userId, position];
}