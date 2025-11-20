// ==========================================

// lib/domain/usecases/user/get_user_profile_with_context.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserProfileWithContext extends UseCase<User, GetUserProfileWithContextParams> {

  GetUserProfileWithContext(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, User>> call(GetUserProfileWithContextParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserProfile(
      userId: params.userId,
      currentUserId: params.currentUserId,
    );
  }
}

class GetUserProfileWithContextParams extends Equatable {

  const GetUserProfileWithContextParams({
    required this.userId,
    this.currentUserId,
  });
  final String userId;
  final String? currentUserId;

  @override
  List<Object?> get props => [userId, currentUserId];
}


