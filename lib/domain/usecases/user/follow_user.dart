// lib/domain/usecases/user/follow_user.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class FollowUser extends UseCase<void, FollowUserParams> {
  final UserRepository repository;

  FollowUser(this.repository);

  @override
  Future<Either<Failure, void>> call(FollowUserParams params) async {
    if (params.currentUserId.isEmpty || params.targetUserId.isEmpty) {
      return const Left(ValidationFailure(message: 'User IDs cannot be empty'));
    }

    if (params.currentUserId == params.targetUserId) {
      return const Left(ValidationFailure(message: 'Cannot follow yourself'));
    }

    return await repository.followUser(
      currentUserId: params.currentUserId,
      targetUserId: params.targetUserId,
    );
  }
}

class FollowUserParams extends Equatable {
  final String currentUserId;
  final String targetUserId;

  const FollowUserParams({
    required this.currentUserId,
    required this.targetUserId,
  });

  @override
  List<Object> get props => [currentUserId, targetUserId];
}

