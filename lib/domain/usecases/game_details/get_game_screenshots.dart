// ==========================================

// lib/domain/usecases/game_details/get_game_screenshots.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/screenshot.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameScreenshots extends UseCase<List<Screenshot>, GetGameScreenshotsParams> {
  final GameRepository repository;

  GetGameScreenshots(this.repository);

  @override
  Future<Either<Failure, List<Screenshot>>> call(GetGameScreenshotsParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return await repository.getGameScreenshots(params.gameId);
  }
}

class GetGameScreenshotsParams extends Equatable {
  final int gameId;

  const GetGameScreenshotsParams({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

