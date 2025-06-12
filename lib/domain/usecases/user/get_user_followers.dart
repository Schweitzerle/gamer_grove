// domain/usecases/user/get_user_followers.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
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

    return await repository.getUserFollowers(params.userId);
  }
}

class GetUserFollowersParams extends Equatable {
  final String userId;

  const GetUserFollowersParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
