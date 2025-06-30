// ==========================================

// lib/domain/usecases/user_collections/get_user_collection_summary.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user/user_collection_sort_options.dart';
import '../../entities/user/user_collection_summary.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetUserCollectionSummary extends UseCase<UserCollectionSummary, GetUserCollectionSummaryParams> {
  final GameRepository repository;

  GetUserCollectionSummary(this.repository);

  @override
  Future<Either<Failure, UserCollectionSummary>> call(GetUserCollectionSummaryParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserCollectionSummary(
      userId: params.userId,
      collectionType: params.collectionType,
    );
  }
}

class GetUserCollectionSummaryParams extends Equatable {
  final String userId;
  final UserCollectionType collectionType;

  const GetUserCollectionSummaryParams({
    required this.userId,
    required this.collectionType,
  });

  @override
  List<Object> get props => [userId, collectionType];
}

