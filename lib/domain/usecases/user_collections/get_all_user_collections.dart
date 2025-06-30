// ==========================================

// lib/domain/usecases/user_collections/get_all_user_collections.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/user/user_collection_sort_options.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetAllUserCollections extends UseCase<Map<UserCollectionType, List<Game>>, GetAllUserCollectionsParams> {
  final GameRepository repository;

  GetAllUserCollections(this.repository);

  @override
  Future<Either<Failure, Map<UserCollectionType, List<Game>>>> call(GetAllUserCollectionsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getAllUserCollections(
      userId: params.userId,
      limitPerCollection: params.limitPerCollection,
    );
  }
}

class GetAllUserCollectionsParams extends Equatable {
  final String userId;
  final int limitPerCollection;

  const GetAllUserCollectionsParams({
    required this.userId,
    this.limitPerCollection = 10,
  });

  @override
  List<Object> get props => [userId, limitPerCollection];
}

