// ==========================================

// lib/domain/usecases/analytics/get_user_gaming_patterns.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetUserGamingPatterns extends UseCase<Map<String, dynamic>, GetUserGamingPatternsParams> {
  final GameRepository repository;

  GetUserGamingPatterns(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetUserGamingPatternsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserGamingPatterns(params.userId);
  }
}

class GetUserGamingPatternsParams extends Equatable {
  final String userId;

  const GetUserGamingPatternsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}