// ==========================================

// lib/domain/usecases/user/unfollow_user.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class UnfollowUser extends UseCase<void, UnfollowUserParams> {
  final UserRepository repository;

  UnfollowUser(this.repository);

  @override
  Future<Either<Failure, void>> call(UnfollowUserParams params) async {
    if (params.currentUserId.isEmpty || params.targetUserId.isEmpty) {
      return const Left(ValidationFailure(message: 'User IDs cannot be empty'));
    }

    return await repository.unfollowUser(
      currentUserId: params.currentUserId,
      targetUserId: params.targetUserId,
    );
  }
}

class UnfollowUserParams extends Equatable {
  final String currentUserId;
  final String targetUserId;

  const UnfollowUserParams({
    required this.currentUserId,
    required this.targetUserId,
  });

  @override
  List<Object> get props => [currentUserId, targetUserId];
}

