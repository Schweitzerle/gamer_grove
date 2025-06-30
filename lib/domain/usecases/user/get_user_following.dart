// domain/usecases/user/get_user_following.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class GetUserFollowing extends UseCase<List<User>, GetUserFollowingParams> {
  final UserRepository repository;

  GetUserFollowing(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(GetUserFollowingParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserFollowing(params.userId);
  }
}

class GetUserFollowingParams extends Equatable {
  final String userId;

  const GetUserFollowingParams({required this.userId});

  @override
  List<Object> get props => [userId];
}