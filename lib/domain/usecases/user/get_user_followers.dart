// ============================================================
// GET FOLLOWERS USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for getting a user's followers.
///
/// Example:
/// ```dart
/// final useCase = GetFollowersUseCase(userRepository);
/// final result = await useCase(GetFollowersParams(
///   userId: 'uuid',
///   limit: 20,
/// ));
///
/// result.fold(
/// );
/// ```
class GetFollowersUseCase implements UseCase<List<User>, GetFollowersParams> {

  GetFollowersUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, List<User>>> call(GetFollowersParams params) async {
    return repository.getUserFollowers(
      userId: params.userId,
      limit: params.limit ?? 50,
      offset: params.offset ?? 0,
    );
  }
}

class GetFollowersParams extends Equatable {

  const GetFollowersParams({
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
