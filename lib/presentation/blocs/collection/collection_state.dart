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

  const GameEnrichmentLoaded(this.enrichmentData);
  final Map<int, Map<String, dynamic>> enrichmentData;

  @override
  List<Object> get props => [enrichmentData];
}

/// State when rating succeeds.
class RatingSuccess extends CollectionState {

  const RatingSuccess({
    required this.gameId,
    required this.rating,
  });
  final int gameId;
  final double rating;

  @override
  List<Object> get props => [gameId, rating];
}

/// State when rating is removed.
class RatingRemoved extends CollectionState {

  const RatingRemoved(this.gameId);
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

/// State when wishlist toggle succeeds.
class WishlistToggled extends CollectionState {

  const WishlistToggled(this.gameId);
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

/// State when recommended toggle succeeds.
class RecommendedToggled extends CollectionState {

  const RecommendedToggled(this.gameId);
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

/// State when top 3 is updated.
class TopThreeUpdated extends CollectionState {

  const TopThreeUpdated(this.gameIds);
  final List<int> gameIds;

  @override
  List<Object> get props => [gameIds];
}

/// State when top 3 is loaded.
class TopThreeLoaded extends CollectionState {

  const TopThreeLoaded(this.gameIds);
  final List<int>? gameIds;

  @override
  List<Object?> get props => [gameIds];
}

/// State when top 3 is cleared.
class TopThreeCleared extends CollectionState {
  const TopThreeCleared();
}

/// State when wishlisted games are loaded.
class WishlistedGamesLoaded extends CollectionState {

  const WishlistedGamesLoaded(this.gameIds);
  final List<int> gameIds;

  @override
  List<Object> get props => [gameIds];
}

/// State when rated games are loaded.
class RatedGamesLoaded extends CollectionState {

  const RatedGamesLoaded(this.games);
  final List<Map<String, dynamic>> games;

  @override
  List<Object> get props => [games];
}

/// State when operation fails.
class CollectionError extends CollectionState {

  const CollectionError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
