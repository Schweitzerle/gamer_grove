// lib/domain/usecases/user/

/// User profile use cases for profile operations.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

// ============================================================
// GET USER PROFILE USE CASE
// ============================================================

/// Use case for getting a user profile.
///
/// Example:
/// ```dart
/// final useCase = GetUserProfileUseCase(userRepository);
/// final result = await useCase(GetUserProfileParams(userId: 'uuid'));
///
/// result.fold(
/// );
/// ```
class GetUserProfileUseCase implements UseCase<User, GetUserProfileParams> {

  GetUserProfileUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, User>> call(GetUserProfileParams params) async {
    if (params.userId != null) {
      return repository.getUserProfile(userId: params.userId!);
    } else {
      return const Left(ValidationFailure(
        message: 'userId must be provided',
      ),);
    }
  }
}

class GetUserProfileParams extends Equatable {

  const GetUserProfileParams({
    this.userId,
    this.username,
  });
  final String? userId;
  final String? username;

  @override
  List<Object?> get props => [userId, username];
}
