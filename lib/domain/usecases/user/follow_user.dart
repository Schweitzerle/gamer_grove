// ============================================================
// FOLLOW USER USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for following a user.
///
/// Example:
/// ```dart
/// final useCase = FollowUserUseCase(userRepository);
/// final result = await useCase(FollowUserParams(
///   currentUserId: 'uuid1',
///   targetUserId: 'uuid2',
/// ));
///
/// result.fold(
/// );
/// ```
class FollowUserUseCase implements UseCase<void, FollowUserParams> {

  FollowUserUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, void>> call(FollowUserParams params) async {
    // Validate not trying to follow self
    if (params.currentUserId == params.targetUserId) {
      return const Left(ValidationFailure(
        message: 'You cannot follow yourself',
      ),);
    }

    // Check if already following (optional - repository handles this)
    final isFollowingResult = await repository.isFollowing(
      currentUserId: params.currentUserId,
      targetUserId: params.targetUserId,
    );

    final alreadyFollowing = isFollowingResult.fold(
      (failure) => false,
      (following) => following,
    );

    if (alreadyFollowing) {
      return const Left(ValidationFailure(
        message: 'You are already following this user',
      ),);
    }

    return repository.followUser(
      currentUserId: params.currentUserId,
      targetUserId: params.targetUserId,
    );
  }
}

class FollowUserParams extends Equatable {

  const FollowUserParams({
    required this.currentUserId,
    required this.targetUserId,
  });
  final String currentUserId;
  final String targetUserId;

  @override
  List<Object> get props => [currentUserId, targetUserId];
}
