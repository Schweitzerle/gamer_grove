// ==================================================

// lib/domain/usecases/events/get_complete_event_details.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event/event.dart';
import '../../entities/game/game.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetCompleteEventDetails extends UseCase<CompleteEventDetails, GetCompleteEventDetailsParams> {
  final EventRepository eventRepository;
  final GameRepository gameRepository;

  GetCompleteEventDetails({
    required this.eventRepository,
    required this.gameRepository,
  });

  @override
  Future<Either<Failure, CompleteEventDetails>> call(GetCompleteEventDetailsParams params) async {
    try {
      // Get event details
      final eventResult = await eventRepository.getEventDetails(params.eventId);

      if (eventResult.isLeft()) {
        return eventResult.fold(
              (failure) => Left(failure),
              (event) => throw Exception('Unexpected success'),
        );
      }

      final event = eventResult.fold((l) => throw Exception('Unexpected failure'), (r) => r);

      // Get featured games if event has games
      List<Game> featuredGames = [];
      if (event.hasGames && params.includeGames) {
        final gamesResult = await gameRepository.getGamesByIds(event.gameIds);
        gamesResult.fold(
              (failure) {
            // Log failure but don't fail the entire operation
          },
              (games) => featuredGames = games,
        );
      }

      return Right(CompleteEventDetails(
        event: event,
        featuredGames: featuredGames,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load complete event details: $e'));
    }
  }
}

class GetCompleteEventDetailsParams extends Equatable {
  final int eventId;
  final bool includeGames;

  const GetCompleteEventDetailsParams({
    required this.eventId,
    this.includeGames = true,
  });

  @override
  List<Object> get props => [eventId, includeGames];
}

// Füge diese copyWith Methode zu deiner CompleteEventDetails Klasse hinzu

class CompleteEventDetails extends Equatable {
  final Event event;
  final List<Game> featuredGames;

  const CompleteEventDetails({
    required this.event,
    required this.featuredGames,
  });

  // Helper getters
  bool get hasFeaturedGames => featuredGames.isNotEmpty;
  int get featuredGamesCount => featuredGames.length;


  CompleteEventDetails copyWith({
    Event? event,
    List<Game>? featuredGames,
  }) {
    return CompleteEventDetails(
      event: event ?? this.event,
      featuredGames: featuredGames ?? this.featuredGames,
    );
  }

  @override
  List<Object> get props => [event, featuredGames];
}
