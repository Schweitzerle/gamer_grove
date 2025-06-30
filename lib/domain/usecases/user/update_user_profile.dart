// domain/usecases/user/update_user_profile.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/input_validator.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class UpdateUserProfile extends UseCase<User, UpdateUserProfileParams> {
  final UserRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateUserProfileParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    // Validate username if provided
    if (params.username != null) {
      final usernameValidation = InputValidator.validateUsername(params.username);
      if (usernameValidation != null) {
        return Left(ValidationFailure(message: usernameValidation));
      }
    }

    // Validate bio if provided
    if (params.bio != null) {
      final bioValidation = InputValidator.validateBio(params.bio);
      if (bioValidation != null) {
        return Left(ValidationFailure(message: bioValidation));
      }
    }

    return await repository.updateUserProfile(
      userId: params.userId,
      username: params.username,
      bio: params.bio,
      avatarUrl: params.avatarUrl,
      country: params.country,
    );
  }
}

class UpdateUserProfileParams extends Equatable {
  final String userId;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final String? country;

  const UpdateUserProfileParams({
    required this.userId,
    this.username,
    this.bio,
    this.avatarUrl,
    this.country,
  });

  @override
  List<Object?> get props => [userId, username, bio, avatarUrl, country];
}
