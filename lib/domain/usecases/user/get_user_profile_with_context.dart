// ==========================================

// lib/domain/usecases/user/get_user_profile_with_context.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class GetUserProfileWithContext extends UseCase<User, GetUserProfileWithContextParams> {
  final UserRepository repository;

  GetUserProfileWithContext(this.repository);

  @override
  Future<Either<Failure, User>> call(GetUserProfileWithContextParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserProfile(
      userId: params.userId,
      currentUserId: params.currentUserId,
    );
  }
}

class GetUserProfileWithContextParams extends Equatable {
  final String userId;
  final String? currentUserId;

  const GetUserProfileWithContextParams({
    required this.userId,
    this.currentUserId,
  });

  @override
  List<Object?> get props => [userId, currentUserId];
}


