import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Creates a new custom collection after validating its name.
///
/// The free/Pro limit is enforced at the call site (presentation) via
/// `requirePro`; this use case validates the name so both the UI and any future
/// server-side path share the same rule.
class CreateCollectionUseCase
    implements UseCase<UserCollection, CreateCollectionParams> {
  CreateCollectionUseCase(this.repository);

  /// Maximum length of a collection name.
  static const int maxNameLength = 60;

  final UserCollectionsRepository repository;

  @override
  Future<Either<Failure, UserCollection>> call(
    CreateCollectionParams params,
  ) {
    final name = params.name.trim();
    if (name.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(message: 'Name cannot be empty')),
      );
    }
    if (name.length > maxNameLength) {
      return Future.value(
        const Left(
          ValidationFailure(
            message: 'Name is too long (max $maxNameLength characters)',
          ),
        ),
      );
    }
    return repository.createCollection(
      userId: params.userId,
      name: name,
      description: params.description?.trim(),
    );
  }
}

class CreateCollectionParams extends Equatable {
  const CreateCollectionParams({
    required this.userId,
    required this.name,
    this.description,
  });

  final String userId;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [userId, name, description];
}
