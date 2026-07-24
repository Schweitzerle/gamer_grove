import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Returns which of the user's collections already contain a given game, so
/// the UI can mark those as added instead of offering a no-op add.
class GetCollectionIdsContainingGameUseCase
    implements UseCase<List<String>, GetCollectionIdsContainingGameParams> {
  GetCollectionIdsContainingGameUseCase(this.repository);

  final UserCollectionsRepository repository;

  @override
  Future<Either<Failure, List<String>>> call(
    GetCollectionIdsContainingGameParams params,
  ) {
    return repository.getCollectionIdsContainingGame(
      userId: params.userId,
      gameId: params.gameId,
    );
  }
}

class GetCollectionIdsContainingGameParams extends Equatable {
  const GetCollectionIdsContainingGameParams({
    required this.userId,
    required this.gameId,
  });

  final String userId;
  final int gameId;

  @override
  List<Object?> get props => [userId, gameId];
}
