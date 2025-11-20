// ============================================================
// UPDATE USER AVATAR USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

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
/// );
/// ```
class UpdateUserAvatarUseCase
    implements UseCase<String, UpdateUserAvatarParams> {

  UpdateUserAvatarUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, String>> call(UpdateUserAvatarParams params) async {
    // Validate image data is not empty
    if (params.imageData.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Image data cannot be empty',
      ),);
    }

    return repository.updateUserAvatar(
      userId: params.userId,
      imageData: params.imageData,
    );
  }
}

class UpdateUserAvatarParams extends Equatable {

  const UpdateUserAvatarParams({
    required this.userId,
    required this.imageData,
  });
  final String userId;
  final String imageData;

  @override
  List<Object> get props => [userId, imageData];
}
