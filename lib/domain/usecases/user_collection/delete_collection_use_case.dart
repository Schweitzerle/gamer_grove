import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Deletes a custom collection and its membership rows.
class DeleteCollectionUseCase implements UseCase<void, DeleteCollectionParams> {
  DeleteCollectionUseCase(this.repository);

  final UserCollectionsRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteCollectionParams params) {
    return repository.deleteCollection(params.collectionId);
  }
}

class DeleteCollectionParams extends Equatable {
  const DeleteCollectionParams({required this.collectionId});

  final String collectionId;

  @override
  List<Object?> get props => [collectionId];
}
