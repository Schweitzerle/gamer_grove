// domain/usecases/user/get_user_profile.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user/user.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class GetUserProfile extends UseCase<User, GetUserProfileParams> {
  final UserRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(GetUserProfileParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserProfile(params.userId);
  }
}

class GetUserProfileParams extends Equatable {
  final String userId;

  const GetUserProfileParams({required this.userId});

  @override
  List<Object> get props => [userId];
}



