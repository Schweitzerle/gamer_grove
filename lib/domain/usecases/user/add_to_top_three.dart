// lib/domain/usecases/user/add_to_top_three.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class AddToTopThree implements UseCase<void, AddToTopThreeParams> {
  final UserRepository repository;

  AddToTopThree(this.repository);

  @override
  Future<Either<Failure, void>> call(AddToTopThreeParams params) async {
    try {
      // Get current top three
      final currentTopThreeResult = await repository.getUserTopThreeGames(params.userId);

      return currentTopThreeResult.fold(
            (failure) => Left(failure),
            (currentTopThree) async {
          // Create new list with the game at the specified position
          List<int> newTopThree = List.from(currentTopThree);

          // Remove the game if it already exists
          newTopThree.remove(params.gameId);

          // If position is specified, insert at that position
          if (params.position != null && params.position! > 0 && params.position! <= 3) {
            // Ensure list has enough space
            while (newTopThree.length < params.position!) {
              newTopThree.add(0); // Use 0 as placeholder
            }

            // Insert at the specified position (converting from 1-based to 0-based)
            newTopThree.insert(params.position! - 1, params.gameId);

            // Keep only the first 3 items
            if (newTopThree.length > 3) {
              newTopThree = newTopThree.take(3).toList();
            }
          } else {
            // No position specified, add to the end
            newTopThree.add(params.gameId);

            // Keep only the first 3 items
            if (newTopThree.length > 3) {
              newTopThree = newTopThree.take(3).toList();
            }
          }

          // Remove any 0 placeholders
          newTopThree = newTopThree.where((id) => id != 0).toList();

          // Update the top three
          return await repository.updateUserTopThreeGames(params.userId, newTopThree);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class AddToTopThreeParams extends Equatable {
  final int gameId;
  final String userId;
  final int? position; // 1, 2, or 3

  const AddToTopThreeParams({
    required this.gameId,
    required this.userId,
    this.position,
  });

  @override
  List<Object?> get props => [gameId, userId, position];
}