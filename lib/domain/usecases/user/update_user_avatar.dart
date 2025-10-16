// ============================================================
// UPDATE USER AVATAR USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import '../../repositories/user_repository.dart';
import '../usecase.dart';

/// Use case for uploading a user avatar.
///
/// Example:
/// ```dart
/// final useCase = UpdateUserAvatarUseCase(userRepository);
/// final result = await useCase(UpdateUserAvatarParams(
///   userId: 'uuid',
///   imageData: base64ImageData,
/// ));
///
/// result.fold(
///   (failure) => print('Upload failed: ${failure.message}'),
///   (url) => print('Avatar uploaded: $url'),
/// );
/// ```
class UpdateUserAvatarUseCase
    implements UseCase<String, UpdateUserAvatarParams> {
  final UserRepository repository;

  UpdateUserAvatarUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateUserAvatarParams params) async {
    // Validate image data is not empty
    if (params.imageData.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Image data cannot be empty',
      ));
    }

    return await repository.updateUserAvatar(
      userId: params.userId,
      imageData: params.imageData,
    );
  }
}

class UpdateUserAvatarParams extends Equatable {
  final String userId;
  final String imageData;

  const UpdateUserAvatarParams({
    required this.userId,
    required this.imageData,
  });

  @override
  List<Object> get props => [userId, imageData];
}
