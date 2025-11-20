// ==========================================

// lib/domain/usecases/user_collections/get_all_user_collections.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_sort_options.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetAllUserCollections extends UseCase<Map<UserCollectionType, List<Game>>, GetAllUserCollectionsParams> {

  GetAllUserCollections(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, Map<UserCollectionType, List<Game>>>> call(GetAllUserCollectionsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getAllUserCollections(
      userId: params.userId,
      limitPerCollection: params.limitPerCollection,
    );
  }
}

class GetAllUserCollectionsParams extends Equatable {

  const GetAllUserCollectionsParams({
    required this.userId,
    this.limitPerCollection = 10,
  });
  final String userId;
  final int limitPerCollection;

  @override
  List<Object> get props => [userId, limitPerCollection];
}

