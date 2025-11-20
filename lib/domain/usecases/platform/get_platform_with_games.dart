// ==================================================
// PLATFORM USE CASE IMPLEMENTATION
// ==================================================

// lib/domain/usecases/platform/get_platform_with_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/platform/platform.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetPlatformWithGames extends UseCase<PlatformWithGames, GetPlatformWithGamesParams> {
  final GameRepository repository;

  GetPlatformWithGames(this.repository);

  @override
  Future<Either<Failure, PlatformWithGames>> call(GetPlatformWithGamesParams params) async {
    try {

      // Get platform details first
      final platformResult = await repository.getPlatformDetails(params.platformId);

      if (platformResult.isLeft()) {
        return platformResult.fold(
              (failure) {
            return Left(failure);
          },
              (platform) => throw Exception('Unexpected success'),
        );
      }

      final platform = platformResult.fold(
            (l) => throw Exception('Unexpected failure'),
            (r) => r,
      );


      List<Game> games = [];

      // Load games for this platform if requested
      if (params.includeGames) {

        final gamesResult = await repository.getGamesByPlatform(
          platformIds: [platform.id],
          limit: params.limit,
          offset: 0,
        );

        games = gamesResult.fold(
              (failure) {
            return <Game>[];
          },
              (gamesList) {
            return gamesList;
          },
        );
      }

      final result = PlatformWithGames(
        platform: platform,
        games: games,
      );

      return Right(result);

    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load platform with games: $e'));
    }
  }
}

class GetPlatformWithGamesParams extends Equatable {
  final int platformId;
  final bool includeGames;
  final int limit;

  const GetPlatformWithGamesParams({
    required this.platformId,
    this.includeGames = true,
    this.limit = 10,
  });

  @override
  List<Object> get props => [platformId, includeGames, limit];
}

class PlatformWithGames extends Equatable {
  final Platform platform;
  final List<Game> games;

  const PlatformWithGames({
    required this.platform,
    required this.games,
  });

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [platform, games];
}