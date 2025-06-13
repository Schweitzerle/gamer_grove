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
    // Get current top three games
    final currentTopThreeResult = await repository.getUserProfile(params.userId);

    return currentTopThreeResult.fold(
          (failure) => Left(failure),
          (user) async {
        // Create new list with the game added (max 3 games)
        final currentTopThree = List<int>.from(user.topThreeGames);

        // Remove if already exists
        currentTopThree.remove(params.gameId);

        // Add to front
        currentTopThree.insert(0, params.gameId);

        // Keep only first 3
        if (currentTopThree.length > 3) {
          currentTopThree.removeLast();
        }

        // Update top three games
        return await repository.updateTopThreeGames(
          userId: params.userId,
          gameIds: currentTopThree,
        );
      },
    );
  }
}

class AddToTopThreeParams extends Equatable {
  final int gameId;
  final String userId;

  const AddToTopThreeParams({
    required this.gameId,
    required this.userId,
  });

  @override
  List<Object> get props => [gameId, userId];
}