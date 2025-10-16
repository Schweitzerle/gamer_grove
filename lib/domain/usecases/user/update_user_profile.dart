// ============================================================
// UPDATE USER PROFILE USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import '../../repositories/user_repository.dart';
import '../usecase.dart';

/// Use case for updating a user profile.
///
/// Example:
/// ```dart
/// final useCase = UpdateUserProfileUseCase(userRepository);
/// final result = await useCase(UpdateUserProfileParams(
///   userId: 'uuid',
///   updates: {
///     'display_name': 'John Doe',
///     'bio': 'Passionate gamer',
///   },
/// ));
///
/// result.fold(
///   (failure) => print('Update failed: ${failure.message}'),
///   (user) => print('Profile updated for ${user.username}'),
/// );
/// ```
class UpdateUserProfileUseCase
    implements UseCase<User, UpdateUserProfileParams> {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateUserProfileParams params) async {
    // Validate display name if provided
    if (params.updates.containsKey('display_name')) {
      final displayName = params.updates['display_name'] as String?;
      if (displayName != null &&
          (displayName.isEmpty || displayName.length > 50)) {
        return const Left(ValidationFailure(
          message: 'Display name must be 1-50 characters',
        ));
      }
    }

    // Validate bio if provided
    if (params.updates.containsKey('bio')) {
      final bio = params.updates['bio'] as String?;
      if (bio != null && bio.length > 500) {
        return const Left(ValidationFailure(
          message: 'Bio must be 500 characters or less',
        ));
      }
    }

    // Validate username if provided
    if (params.updates.containsKey('username')) {
      final username = params.updates['username'] as String;
      final usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');
      if (!usernameRegex.hasMatch(username)) {
        return const Left(ValidationFailure(
          message:
              'Username must be 3-20 characters, lowercase alphanumeric and underscores only',
        ));
      }
    }

    return await repository.updateUserProfile(
      userId: params.userId,
      username: params.updates['username'] as String?,
      bio: params.updates['bio'] as String?,
      avatarUrl: params.updates['avatar_url'] as String?,
      country: params.updates['country'] as String?,
      isProfilePublic: params.updates['is_profile_public'] as bool?,
      showRatedGames: params.updates['show_rated_games'] as bool?,
      showRecommendedGames: params.updates['show_recommended_games'] as bool?,
      showTopThree: params.updates['show_top_three'] as bool?,
    );
  }
}

class UpdateUserProfileParams extends Equatable {
  final String userId;
  final Map<String, dynamic> updates;

  const UpdateUserProfileParams({
    required this.userId,
    required this.updates,
  });

  @override
  List<Object> get props => [userId, updates];
}
