import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Removes a game from a custom collection.
class RemoveGameFromCollectionUseCase
    implements UseCase<void, RemoveGameFromCollectionParams> {
  RemoveGameFromCollectionUseCase(this.repository);

  final UserCollectionsRepository repository;

  @override
  Future<Either<Failure, void>> call(
    RemoveGameFromCollectionParams params,
  ) {
    return repository.removeGameFromCollection(
      collectionId: params.collectionId,
      gameId: params.gameId,
    );
  }
}

class RemoveGameFromCollectionParams extends Equatable {
  const RemoveGameFromCollectionParams({
    required this.collectionId,
    required this.gameId,
  });

  final String collectionId;
  final int gameId;

  @override
  List<Object?> get props => [collectionId, gameId];
}
