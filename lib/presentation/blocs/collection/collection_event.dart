// lib/presentation/blocs/collection/collection_bloc.dart

/// Collection BLoC for handling game collection operations.
library;

import 'package:equatable/equatable.dart';

// ============================================================
// EVENTS
// ============================================================

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load enriched game data for multiple games.
/// This is the PERFORMANCE-CRITICAL event!
class LoadGameEnrichmentEvent extends CollectionEvent {

  const LoadGameEnrichmentEvent({
    required this.userId,
    required this.gameIds,
  });
  final String userId;
  final List<int> gameIds;

  @override
  List<Object> get props => [userId, gameIds];
}

/// Event to rate a game.
class RateGameEvent extends CollectionEvent {

  const RateGameEvent({
    required this.userId,
    required this.gameId,
    required this.rating,
  });
  final String userId;
  final int gameId;
  final double rating;

  @override
  List<Object> get props => [userId, gameId, rating];
}

/// Event to remove a rating.
class RemoveRatingEvent extends CollectionEvent {

  const RemoveRatingEvent({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}

/// Event to toggle wishlist.
class ToggleWishlistEvent extends CollectionEvent {

  const ToggleWishlistEvent({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}

/// Event to toggle recommended.
class ToggleRecommendedEvent extends CollectionEvent {

  const ToggleRecommendedEvent({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}

/// Event to update top 3 games.
class UpdateTopThreeEvent extends CollectionEvent {

  const UpdateTopThreeEvent({
    required this.userId,
    required this.gameIds,
  });
  final String userId;
  final List<int> gameIds;

  @override
  List<Object> get props => [userId, gameIds];
}

/// Event to load top 3 games.
class LoadTopThreeEvent extends CollectionEvent {

  const LoadTopThreeEvent({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to clear top 3 games.
class ClearTopThreeEvent extends CollectionEvent {

  const ClearTopThreeEvent({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to load wishlisted games.
class LoadWishlistedGamesEvent extends CollectionEvent {

  const LoadWishlistedGamesEvent({
    required this.userId,
    this.limit,
    this.offset,
  });
  final String userId;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [userId, limit, offset];
}

/// Event to load rated games.
class LoadRatedGamesEvent extends CollectionEvent {

  const LoadRatedGamesEvent({
    required this.userId,
    this.limit,
    this.offset,
  });
  final String userId;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [userId, limit, offset];
}
