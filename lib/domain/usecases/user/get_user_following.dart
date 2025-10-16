// ============================================================
// GET FOLLOWING USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import '../../repositories/user_repository.dart';
import '../usecase.dart';

/// Use case for getting users that a user follows.
///
/// Example:
/// ```dart
/// final useCase = GetFollowingUseCase(userRepository);
/// final result = await useCase(GetFollowingParams(
///   userId: 'uuid',
///   limit: 20,
/// ));
///
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (following) => print('Following ${following.length} users'),
/// );
/// ```
class GetFollowingUseCase implements UseCase<List<User>, GetFollowingParams> {
  final UserRepository repository;

  GetFollowingUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(GetFollowingParams params) async {
    return await repository.getUserFollowing(
      userId: params.userId,
      limit: params.limit ?? 50,
      offset: params.offset ?? 0,
    );
  }
}

class GetFollowingParams extends Equatable {
  final String userId;
  final int? limit;
  final int? offset;

  const GetFollowingParams({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}
