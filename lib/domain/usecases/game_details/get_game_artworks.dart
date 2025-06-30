// ==========================================

// lib/domain/usecases/game_details/get_game_artwork.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/artwork.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameArtwork extends UseCase<List<Artwork>, GetGameArtworkParams> {
  final GameRepository repository;

  GetGameArtwork(this.repository);

  @override
  Future<Either<Failure, List<Artwork>>> call(GetGameArtworkParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return await repository.getGameArtwork(params.gameId);
  }
}

class GetGameArtworkParams extends Equatable {
  final int gameId;

  const GetGameArtworkParams({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

