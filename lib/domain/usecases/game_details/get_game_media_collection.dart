// ==========================================

// lib/domain/usecases/game_details/get_game_media_collection.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game_media_collection.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameMediaCollection extends UseCase<GameMediaCollection, GetGameMediaCollectionParams> {
  final GameRepository repository;

  GetGameMediaCollection(this.repository);

  @override
  Future<Either<Failure, GameMediaCollection>> call(GetGameMediaCollectionParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return await repository.getGameMediaCollection(params.gameId);
  }
}

class GetGameMediaCollectionParams extends Equatable {
  final int gameId;

  const GetGameMediaCollectionParams({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

