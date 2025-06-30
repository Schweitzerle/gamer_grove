// ==========================================

// lib/domain/usecases/discovery/get_discovery_challenges.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/recommendations/discovery_challenge.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetDiscoveryChallenges extends UseCase<List<DiscoveryChallenge>, GetDiscoveryChallengesParams> {
  final GameRepository repository;

  GetDiscoveryChallenges(this.repository);

  @override
  Future<Either<Failure, List<DiscoveryChallenge>>> call(GetDiscoveryChallengesParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getDiscoveryChallenges(params.userId);
  }
}

class GetDiscoveryChallengesParams extends Equatable {
  final String userId;

  const GetDiscoveryChallengesParams({required this.userId});

  @override
  List<Object> get props => [userId];
}