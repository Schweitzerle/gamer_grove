import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Loads all custom collections owned by a user.
class GetUserCollectionsUseCase
    implements UseCase<List<UserCollection>, GetUserCollectionsParams> {
  GetUserCollectionsUseCase(this.repository);

  final UserCollectionsRepository repository;

  @override
  Future<Either<Failure, List<UserCollection>>> call(
    GetUserCollectionsParams params,
  ) {
    return repository.getUserCollections(params.userId);
  }
}

class GetUserCollectionsParams extends Equatable {
  const GetUserCollectionsParams({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}
