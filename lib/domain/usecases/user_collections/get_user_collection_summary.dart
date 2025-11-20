// ==========================================

// lib/domain/usecases/user_collections/get_user_collection_summary.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_sort_options.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_summary.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserCollectionSummary extends UseCase<UserCollectionSummary, GetUserCollectionSummaryParams> {

  GetUserCollectionSummary(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, UserCollectionSummary>> call(GetUserCollectionSummaryParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserCollectionSummary(
      userId: params.userId,
      collectionType: params.collectionType,
    );
  }
}

class GetUserCollectionSummaryParams extends Equatable {

  const GetUserCollectionSummaryParams({
    required this.userId,
    required this.collectionType,
  });
  final String userId;
  final UserCollectionType collectionType;

  @override
  List<Object> get props => [userId, collectionType];
}

