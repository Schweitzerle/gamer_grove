// ==========================================

// lib/domain/usecases/game_details/get_game_videos.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game_video.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameVideos extends UseCase<List<GameVideo>, GetGameVideosParams> {

  GetGameVideos(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<GameVideo>>> call(GetGameVideosParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return repository.getGameVideos(params.gameId);
  }
}

class GetGameVideosParams extends Equatable {

  const GetGameVideosParams({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

