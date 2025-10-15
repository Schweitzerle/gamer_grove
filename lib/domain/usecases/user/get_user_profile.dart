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

    return await repository.getUserProfile(
      userId: params.userId,
      currentUserId: params.currentUserId,
    );
  }
}

class GetUserProfileParams extends Equatable {
  final String userId;
  final String? currentUserId; // For privacy checks and social context
  final bool includePrivateData;
  final bool includeSocialStats;
  final bool includeTopThree;
  final bool includeGamingStats;

  const GetUserProfileParams({
    required this.userId,
    this.currentUserId,
    this.includePrivateData = false,
    this.includeSocialStats = true,
    this.includeTopThree = true,
    this.includeGamingStats = true,
  });

  // Convenience constructors
  const GetUserProfileParams.basic({
    required this.userId,
    this.currentUserId,
  })  : includePrivateData = false,
        includeSocialStats = true,
        includeTopThree = false,
        includeGamingStats = false;

  const GetUserProfileParams.detailed({
    required this.userId,
    this.currentUserId,
  })  : includePrivateData = false,
        includeSocialStats = true,
        includeTopThree = true,
        includeGamingStats = true;

  const GetUserProfileParams.ownProfile({
    required this.userId,
  })  : currentUserId = userId,
        includePrivateData = true,
        includeSocialStats = true,
        includeTopThree = true,
        includeGamingStats = true;

  @override
  List<Object?> get props => [
        userId,
        currentUserId,
        includePrivateData,
        includeSocialStats,
        includeTopThree,
        includeGamingStats,
      ];
}
