// ==========================================

// lib/domain/usecases/game_details/get_game_videos.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game_video.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameVideos extends UseCase<List<GameVideo>, GetGameVideosParams> {
  final GameRepository repository;

  GetGameVideos(this.repository);

  @override
  Future<Either<Failure, List<GameVideo>>> call(GetGameVideosParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return await repository.getGameVideos(params.gameId);
  }
}

class GetGameVideosParams extends Equatable {
  final int gameId;

  const GetGameVideosParams({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

