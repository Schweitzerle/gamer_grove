import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';
import 'package:gamer_grove/domain/usecases/user_collection/create_collection_use_case.dart';

/// Updates a collection's mutable fields (rename, description, cover, sharing).
class UpdateCollectionUseCase
    implements UseCase<UserCollection, UpdateCollectionParams> {
  UpdateCollectionUseCase(this.repository);

  final UserCollectionsRepository repository;

  @override
  Future<Either<Failure, UserCollection>> call(
    UpdateCollectionParams params,
  ) {
    final name = params.name?.trim();
    if (name != null && name.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(message: 'Name cannot be empty')),
      );
    }
    if (name != null && name.length > CreateCollectionUseCase.maxNameLength) {
      return Future.value(
        const Left(
          ValidationFailure(
            message: 'Name is too long '
                '(max ${CreateCollectionUseCase.maxNameLength} characters)',
          ),
        ),
      );
    }
    return repository.updateCollection(
      collectionId: params.collectionId,
      name: name,
      description: params.description?.trim(),
      coverGameId: params.coverGameId,
      isPublic: params.isPublic,
    );
  }
}

class UpdateCollectionParams extends Equatable {
  const UpdateCollectionParams({
    required this.collectionId,
    this.name,
    this.description,
    this.coverGameId,
    this.isPublic,
  });

  final String collectionId;
  final String? name;
  final String? description;
  final int? coverGameId;
  final bool? isPublic;

  @override
  List<Object?> get props => [
        collectionId,
        name,
        description,
        coverGameId,
        isPublic,
      ];
}
