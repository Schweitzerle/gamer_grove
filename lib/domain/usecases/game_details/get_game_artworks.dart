// ==========================================

// lib/domain/usecases/game_details/get_game_artwork.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/artwork.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameArtwork extends UseCase<List<Artwork>, GetGameArtworkParams> {

  GetGameArtwork(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Artwork>>> call(GetGameArtworkParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return repository.getGameArtwork(params.gameId);
  }
}

class GetGameArtworkParams extends Equatable {

  const GetGameArtworkParams({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

