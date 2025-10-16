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
  final String userId;
  final List<int> gameIds;

  const LoadGameEnrichmentEvent({
    required this.userId,
    required this.gameIds,
  });

  @override
  List<Object> get props => [userId, gameIds];
}

/// Event to rate a game.
class RateGameEvent extends CollectionEvent {
  final String userId;
  final int gameId;
  final double rating;

  const RateGameEvent({
    required this.userId,
    required this.gameId,
    required this.rating,
  });

  @override
  List<Object> get props => [userId, gameId, rating];
}

/// Event to remove a rating.
class RemoveRatingEvent extends CollectionEvent {
  final String userId;
  final int gameId;

  const RemoveRatingEvent({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}

/// Event to toggle wishlist.
class ToggleWishlistEvent extends CollectionEvent {
  final String userId;
  final int gameId;

  const ToggleWishlistEvent({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}

/// Event to toggle recommended.
class ToggleRecommendedEvent extends CollectionEvent {
  final String userId;
  final int gameId;

  const ToggleRecommendedEvent({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}

/// Event to update top 3 games.
class UpdateTopThreeEvent extends CollectionEvent {
  final String userId;
  final List<int> gameIds;

  const UpdateTopThreeEvent({
    required this.userId,
    required this.gameIds,
  });

  @override
  List<Object> get props => [userId, gameIds];
}

/// Event to load top 3 games.
class LoadTopThreeEvent extends CollectionEvent {
  final String userId;

  const LoadTopThreeEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Event to clear top 3 games.
class ClearTopThreeEvent extends CollectionEvent {
  final String userId;

  const ClearTopThreeEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Event to load wishlisted games.
class LoadWishlistedGamesEvent extends CollectionEvent {
  final String userId;
  final int? limit;
  final int? offset;

  const LoadWishlistedGamesEvent({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}

/// Event to load rated games.
class LoadRatedGamesEvent extends CollectionEvent {
  final String userId;
  final int? limit;
  final int? offset;

  const LoadRatedGamesEvent({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}
