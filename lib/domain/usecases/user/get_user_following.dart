// ============================================================
// GET FOLLOWING USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

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
/// );
/// ```
class GetFollowingUseCase implements UseCase<List<User>, GetFollowingParams> {

  GetFollowingUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, List<User>>> call(GetFollowingParams params) async {
    return repository.getUserFollowing(
      userId: params.userId,
      limit: params.limit ?? 50,
      offset: params.offset ?? 0,
    );
  }
}

class GetFollowingParams extends Equatable {

  const GetFollowingParams({
    required this.userId,
    this.limit,
    this.offset,
  });
  final String userId;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [userId, limit, offset];
}
