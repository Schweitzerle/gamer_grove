// ==========================================

// lib/domain/usecases/user_collections/get_user_gaming_statistics.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserGamingStatistics extends UseCase<Map<String, dynamic>, GetUserGamingStatisticsParams> {

  GetUserGamingStatistics(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetUserGamingStatisticsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserGamingStatistics(params.userId);
  }
}

class GetUserGamingStatisticsParams extends Equatable {

  const GetUserGamingStatisticsParams({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}

