import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Returns the ordered game ids of a collection (for detail loading).
class GetCollectionGameIdsUseCase
    implements UseCase<List<int>, GetCollectionGameIdsParams> {
  GetCollectionGameIdsUseCase(this.repository);

  final UserCollectionsRepository repository;

  @override
  Future<Either<Failure, List<int>>> call(
    GetCollectionGameIdsParams params,
  ) {
    return repository.getCollectionGameIds(params.collectionId);
  }
}

class GetCollectionGameIdsParams extends Equatable {
  const GetCollectionGameIdsParams({required this.collectionId});

  final String collectionId;

  @override
  List<Object?> get props => [collectionId];
}
