// ============================================================
// STATES
// ============================================================

import 'package:equatable/equatable.dart';

abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class CollectionInitial extends CollectionState {
  const CollectionInitial();
}

/// Loading state during operations.
class CollectionLoading extends CollectionState {
  const CollectionLoading();
}

/// State when game enrichment data is loaded.
/// This is the PERFORMANCE-CRITICAL state!
class GameEnrichmentLoaded extends CollectionState {
  final Map<int, Map<String, dynamic>> enrichmentData;

  const GameEnrichmentLoaded(this.enrichmentData);

  @override
  List<Object> get props => [enrichmentData];
}

/// State when rating succeeds.
class RatingSuccess extends CollectionState {
  final int gameId;
  final double rating;

  const RatingSuccess({
    required this.gameId,
    required this.rating,
  });

  @override
  List<Object> get props => [gameId, rating];
}

/// State when rating is removed.
class RatingRemoved extends CollectionState {
  final int gameId;

  const RatingRemoved(this.gameId);

  @override
  List<Object> get props => [gameId];
}

/// State when wishlist toggle succeeds.
class WishlistToggled extends CollectionState {
  final int gameId;

  const WishlistToggled(this.gameId);

  @override
  List<Object> get props => [gameId];
}

/// State when recommended toggle succeeds.
class RecommendedToggled extends CollectionState {
  final int gameId;

  const RecommendedToggled(this.gameId);

  @override
  List<Object> get props => [gameId];
}

/// State when top 3 is updated.
class TopThreeUpdated extends CollectionState {
  final List<int> gameIds;

  const TopThreeUpdated(this.gameIds);

  @override
  List<Object> get props => [gameIds];
}

/// State when top 3 is loaded.
class TopThreeLoaded extends CollectionState {
  final List<int>? gameIds;

  const TopThreeLoaded(this.gameIds);

  @override
  List<Object?> get props => [gameIds];
}

/// State when top 3 is cleared.
class TopThreeCleared extends CollectionState {
  const TopThreeCleared();
}

/// State when wishlisted games are loaded.
class WishlistedGamesLoaded extends CollectionState {
  final List<int> gameIds;

  const WishlistedGamesLoaded(this.gameIds);

  @override
  List<Object> get props => [gameIds];
}

/// State when rated games are loaded.
class RatedGamesLoaded extends CollectionState {
  final List<Map<String, dynamic>> games;

  const RatedGamesLoaded(this.games);

  @override
  List<Object> get props => [games];
}

/// State when operation fails.
class CollectionError extends CollectionState {
  final String message;

  const CollectionError(this.message);

  @override
  List<Object> get props => [message];
}
