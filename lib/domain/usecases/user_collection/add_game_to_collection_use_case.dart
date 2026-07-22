import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Adds a game to a custom collection (idempotent).
class AddGameToCollectionUseCase
    implements UseCase<void, AddGameToCollectionParams> {
  AddGameToCollectionUseCase(this.repository);

  final UserCollectionsRepository repository;

  @override
  Future<Either<Failure, void>> call(AddGameToCollectionParams params) {
    return repository.addGameToCollection(
      collectionId: params.collectionId,
      gameId: params.gameId,
    );
  }
}

class AddGameToCollectionParams extends Equatable {
  const AddGameToCollectionParams({
    required this.collectionId,
    required this.gameId,
  });

  final String collectionId;
  final int gameId;

  @override
  List<Object?> get props => [collectionId, gameId];
}
