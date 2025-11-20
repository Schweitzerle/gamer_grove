// ==========================================

// lib/domain/usecases/game_details/get_game_media_collection.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game_media_collection.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameMediaCollection extends UseCase<GameMediaCollection, GetGameMediaCollectionParams> {

  GetGameMediaCollection(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, GameMediaCollection>> call(GetGameMediaCollectionParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return repository.getGameMediaCollection(params.gameId);
  }
}

class GetGameMediaCollectionParams extends Equatable {

  const GetGameMediaCollectionParams({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

