// ==========================================

// lib/domain/usecases/game_details/get_enhanced_game_details.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetEnhancedGameDetails
    extends UseCase<Game, GetEnhancedGameDetailsParams> {
  final GameRepository repository;

  GetEnhancedGameDetails(this.repository);

  @override
  Future<Either<Failure, Game>> call(
      GetEnhancedGameDetailsParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return await repository.getEnhancedGameDetails(
      gameId: params.gameId,
      userId: params.userId,
      includeCharacters: params.includeCharacters,
      includeEvents: params.includeEvents,
      includeMedia: params.includeMedia,
    );
  }
}

class GetEnhancedGameDetailsParams extends Equatable {
  final int gameId;
  final String? userId;
  final bool includeCharacters;
  final bool includeEvents;
  final bool includeMedia;

  const GetEnhancedGameDetailsParams({
    required this.gameId,
    this.userId,
    this.includeCharacters = true,
    this.includeEvents = true,
    this.includeMedia = true,
  });

  // Quick constructors for different use cases
  const GetEnhancedGameDetailsParams.fullDetails({
    required this.gameId,
    this.userId,
  })  : includeCharacters = true,
        includeEvents = true,
        includeMedia = true;

  const GetEnhancedGameDetailsParams.mediaOnly({
    required this.gameId,
    this.userId,
  })  : includeCharacters = false,
        includeEvents = false,
        includeMedia = true;

  const GetEnhancedGameDetailsParams.charactersAndEvents({
    required this.gameId,
    this.userId,
  })  : includeCharacters = true,
        includeEvents = true,
        includeMedia = false;

  @override
  List<Object?> get props =>
      [gameId, userId, includeCharacters, includeEvents, includeMedia];
}
