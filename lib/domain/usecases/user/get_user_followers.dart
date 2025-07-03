// domain/usecases/user/get_user_followers.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class GetUserFollowers extends UseCase<List<User>, GetUserFollowersParams> {
  final UserRepository repository;

  GetUserFollowers(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(GetUserFollowersParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    if (params.limit <= 0) {
      return const Left(ValidationFailure(message: 'Limit must be greater than 0'));
    }

    if (params.offset < 0) {
      return const Left(ValidationFailure(message: 'Offset cannot be negative'));
    }

    return await repository.getUserFollowers(
      userId: params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserFollowersParams extends Equatable {
  final String userId;
  final String? currentUserId; // For social context (which followers you also follow)
  final int limit;
  final int offset;

  const GetUserFollowersParams({
    required this.userId,
    this.currentUserId,
    this.limit = 20,
    this.offset = 0,
  });

  // Convenience constructors
  GetUserFollowersParams.firstPage({
    required this.userId,
    this.currentUserId,
    this.limit = 20,
  }) : offset = 0;

  GetUserFollowersParams.nextPage({
    required this.userId,
    this.currentUserId,
    required int currentCount,
    this.limit = 20,
  }) : offset = currentCount;

  @override
  List<Object?> get props => [userId, currentUserId, limit, offset];
}