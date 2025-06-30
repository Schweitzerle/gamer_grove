// ==========================================

// lib/domain/usecases/user_collections/get_user_gaming_statistics.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetUserGamingStatistics extends UseCase<Map<String, dynamic>, GetUserGamingStatisticsParams> {
  final GameRepository repository;

  GetUserGamingStatistics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetUserGamingStatisticsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserGamingStatistics(params.userId);
  }
}

class GetUserGamingStatisticsParams extends Equatable {
  final String userId;

  const GetUserGamingStatisticsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

