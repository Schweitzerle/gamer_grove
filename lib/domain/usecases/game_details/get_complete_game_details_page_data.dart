// ==========================================

// lib/domain/usecases/game_details/get_complete_game_detail_page_data.dart
// Composite Use Case for efficient Game Detail page loading
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/character/character.dart';
import '../../entities/event/event.dart';
import '../../entities/game/game_media_collection.dart';
import '../../entities/game/game_video.dart';
import '../base_usecase.dart';
import 'get_enhanced_game_details.dart';
import 'get_game_characters.dart';

class GetCompleteGameDetailPageData extends UseCase<GameDetailPageData, GetCompleteGameDetailPageDataParams> {
  final GetEnhancedGameDetails getEnhancedGameDetails;

  GetCompleteGameDetailPageData({
    required this.getEnhancedGameDetails,
  });

  @override
  Future<Either<Failure, GameDetailPageData>> call(GetCompleteGameDetailPageDataParams params) async {
    try {
      // Get enhanced game details with all content
      final gameResult = await getEnhancedGameDetails(GetEnhancedGameDetailsParams.fullDetails(
        gameId: params.gameId,
        userId: params.userId,
      ));

      if (gameResult.isLeft()) {
        return gameResult.fold(
              (failure) => Left(failure),
              (game) => throw Exception('Unexpected success'),
        );
      }

      final game = gameResult.fold((l) => throw Exception('Unexpected failure'), (r) => r);

      return Right(GameDetailPageData(
        game: game,
        characters: game.characters ?? [],
        events: game.events ?? [],
        mediaCollection: GameMediaCollection(
          gameId: game.id,
          videos: game.videos ?? [],
          screenshots: game.screenshots ?? [],
          artworks: game.artworks ?? [],
        ),
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game detail page data: $e'));
    }
  }
}

class GetCompleteGameDetailPageDataParams extends Equatable {
  final int gameId;
  final String? userId;

  const GetCompleteGameDetailPageDataParams({
    required this.gameId,
    this.userId,
  });

  @override
  List<Object?> get props => [gameId, userId];
}

class GameDetailPageData extends Equatable {
  final Game game;
  final List<Character> characters;
  final List<Event> events;
  final GameMediaCollection mediaCollection;

  const GameDetailPageData({
    required this.game,
    required this.characters,
    required this.events,
    required this.mediaCollection,
  });

  // Helper getters
  bool get hasCharacters => characters.isNotEmpty;
  bool get hasEvents => events.isNotEmpty;
  bool get hasMedia => mediaCollection.hasAnyMedia;

  int get totalContentItems => characters.length + events.length + mediaCollection.totalMediaCount;

  @override
  List<Object> get props => [game, characters, events, mediaCollection];
}