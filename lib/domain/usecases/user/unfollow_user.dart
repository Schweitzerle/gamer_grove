// ============================================================
// UNFOLLOW USER USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for unfollowing a user.
///
/// Example:
/// ```dart
/// final useCase = UnfollowUserUseCase(userRepository);
/// final result = await useCase(UnfollowUserParams(
///   currentUserId: 'uuid1',
///   targetUserId: 'uuid2',
/// ));
///
/// result.fold(
/// );
/// ```
class UnfollowUserUseCase implements UseCase<void, UnfollowUserParams> {

  UnfollowUserUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, void>> call(UnfollowUserParams params) async {
    // Validate not trying to unfollow self
    if (params.currentUserId == params.targetUserId) {
      return const Left(ValidationFailure(
        message: 'Invalid operation',
      ),);
    }

    // Check if currently following (optional - repository handles this)
    final isFollowingResult = await repository.isFollowing(
      currentUserId: params.currentUserId,
      targetUserId: params.targetUserId,
    );

    final isFollowing = isFollowingResult.fold(
      (failure) => false,
      (following) => following,
    );

    if (!isFollowing) {
      return const Left(ValidationFailure(
        message: 'You are not following this user',
      ),);
    }

    return repository.unfollowUser(
      currentUserId: params.currentUserId,
      targetUserId: params.targetUserId,
    );
  }
}

class UnfollowUserParams extends Equatable {

  const UnfollowUserParams({
    required this.currentUserId,
    required this.targetUserId,
  });
  final String currentUserId;
  final String targetUserId;

  @override
  List<Object> get props => [currentUserId, targetUserId];
}
