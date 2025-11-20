// ==========================================

// lib/domain/usecases/game_details/get_game_screenshots.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/screenshot.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameScreenshots extends UseCase<List<Screenshot>, GetGameScreenshotsParams> {

  GetGameScreenshots(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Screenshot>>> call(GetGameScreenshotsParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return repository.getGameScreenshots(params.gameId);
  }
}

class GetGameScreenshotsParams extends Equatable {

  const GetGameScreenshotsParams({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

