// ==========================================

// lib/domain/usecases/game_details/get_complete_game_detail_page_data.dart
// Composite Use Case for efficient Game Detail page loading
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/game/game_media_collection.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';
import 'package:gamer_grove/domain/usecases/game_details/get_enhanced_game_details.dart';

class GetCompleteGameDetailPageData
    extends UseCase<GameDetailPageData, GetCompleteGameDetailPageDataParams> {

  GetCompleteGameDetailPageData({
    required this.getEnhancedGameDetails,
  });
  final GetEnhancedGameDetails getEnhancedGameDetails;

  @override
  Future<Either<Failure, GameDetailPageData>> call(
      GetCompleteGameDetailPageDataParams params,) async {
    try {
      // Get enhanced game details with all content
      final gameResult =
          await getEnhancedGameDetails(GetEnhancedGameDetailsParams.fullDetails(
        gameId: params.gameId,
        userId: params.userId,
      ),);

      if (gameResult.isLeft()) {
        return gameResult.fold(
          Left.new,
          (game) => throw Exception('Unexpected success'),
        );
      }

      final game = gameResult.fold(
          (l) => throw Exception('Unexpected failure'), (r) => r,);

      return Right(GameDetailPageData(
        game: game,
        characters: game.characters,
        events: game.events,
        mediaCollection: GameMediaCollection(
          gameId: game.id,
          videos: game.videos,
          screenshots: game.screenshots,
          artworks: game.artworks,
        ),
      ),);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to load game detail page data: $e'),);
    }
  }
}

class GetCompleteGameDetailPageDataParams extends Equatable {

  const GetCompleteGameDetailPageDataParams({
    required this.gameId,
    this.userId,
  });
  final int gameId;
  final String? userId;

  @override
  List<Object?> get props => [gameId, userId];
}

class GameDetailPageData extends Equatable {

  const GameDetailPageData({
    required this.game,
    required this.characters,
    required this.events,
    required this.mediaCollection,
  });
  final Game game;
  final List<Character> characters;
  final List<Event> events;
  final GameMediaCollection mediaCollection;

  // Helper getters
  bool get hasCharacters => characters.isNotEmpty;
  bool get hasEvents => events.isNotEmpty;
  bool get hasMedia => mediaCollection.hasAnyMedia;

  int get totalContentItems =>
      characters.length + events.length + mediaCollection.totalMediaCount;

  @override
  List<Object> get props => [game, characters, events, mediaCollection];
}
