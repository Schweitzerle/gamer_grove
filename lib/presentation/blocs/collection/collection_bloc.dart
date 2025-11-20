// ============================================================
// BLOC
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/usecases/collection/clear_top_three_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/get_rated_games_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/get_top_three_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/get_user_game_data_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/get_wishlisted_games_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/rate_game_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/remove_rating_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/toggle_recommended_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/toggle_wishlist_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/update_top_three_use_case.dart';
import 'package:gamer_grove/presentation/blocs/collection/collection_event.dart';
import 'package:gamer_grove/presentation/blocs/collection/collection_state.dart';

/// BLoC for handling game collection operations.
///
/// Example:
/// ```dart
/// // Load enrichment data (CRITICAL for performance!)
/// context.read<CollectionBloc>().add(
///   LoadGameEnrichmentEvent(
///     userId: userId,
///     gameIds: [1942, 1905, 113],
///   ),
/// );
///
/// // Rate a game
/// context.read<CollectionBloc>().add(
///   RateGameEvent(
///     userId: userId,
///     gameId: 1942,
///     rating: 9.5,
///   ),
/// );
///
/// // Toggle wishlist
/// context.read<CollectionBloc>().add(
///   ToggleWishlistEvent(
///     userId: userId,
///     gameId: 1942,
///   ),
/// );
///
/// // Update top 3
/// context.read<CollectionBloc>().add(
///   UpdateTopThreeEvent(
///     userId: userId,
///     gameIds: [1942, 1905, 113],
///   ),
/// );
/// ```
class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {

  CollectionBloc({
    required this.getUserGameDataUseCase,
    required this.rateGameUseCase,
    required this.removeRatingUseCase,
    required this.toggleWishlistUseCase,
    required this.toggleRecommendedUseCase,
    required this.updateTopThreeUseCase,
    required this.getTopThreeUseCase,
    required this.clearTopThreeUseCase,
    required this.getWishlistedGamesUseCase,
    required this.getRatedGamesUseCase,
  }) : super(const CollectionInitial()) {
    on<LoadGameEnrichmentEvent>(_onLoadGameEnrichment);
    on<RateGameEvent>(_onRateGame);
    on<RemoveRatingEvent>(_onRemoveRating);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<ToggleRecommendedEvent>(_onToggleRecommended);
    on<UpdateTopThreeEvent>(_onUpdateTopThree);
    on<LoadTopThreeEvent>(_onLoadTopThree);
    on<ClearTopThreeEvent>(_onClearTopThree);
    on<LoadWishlistedGamesEvent>(_onLoadWishlistedGames);
    on<LoadRatedGamesEvent>(_onLoadRatedGames);
  }
  final GetUserGameDataUseCase getUserGameDataUseCase;
  final RateGameUseCase rateGameUseCase;
  final RemoveRatingUseCase removeRatingUseCase;
  final ToggleWishlistUseCase toggleWishlistUseCase;
  final ToggleRecommendedUseCase toggleRecommendedUseCase;
  final UpdateTopThreeUseCase updateTopThreeUseCase;
  final GetTopThreeUseCase getTopThreeUseCase;
  final ClearTopThreeUseCase clearTopThreeUseCase;
  final GetWishlistedGamesUseCase getWishlistedGamesUseCase;
  final GetRatedGamesUseCase getRatedGamesUseCase;

  /// Loads enriched game data for multiple games.
  /// This is the PERFORMANCE-CRITICAL handler!
  Future<void> _onLoadGameEnrichment(
    LoadGameEnrichmentEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await getUserGameDataUseCase(
      GetUserGameDataParams(
        userId: event.userId,
        gameIds: event.gameIds,
      ),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (enrichmentData) => emit(GameEnrichmentLoaded(enrichmentData)),
    );
  }

  /// Rates a game.
  Future<void> _onRateGame(
    RateGameEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await rateGameUseCase(
      RateGameParams(
        userId: event.userId,
        gameId: event.gameId,
        rating: event.rating,
      ),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (_) => emit(RatingSuccess(gameId: event.gameId, rating: event.rating)),
    );
  }

  /// Removes a rating.
  Future<void> _onRemoveRating(
    RemoveRatingEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await removeRatingUseCase(
      RemoveRatingParams(
        userId: event.userId,
        gameId: event.gameId,
      ),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (_) => emit(RatingRemoved(event.gameId)),
    );
  }

  /// Toggles wishlist status.
  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await toggleWishlistUseCase(
      ToggleWishlistParams(
        userId: event.userId,
        gameId: event.gameId,
      ),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (_) => emit(WishlistToggled(event.gameId)),
    );
  }

  /// Toggles recommended status.
  Future<void> _onToggleRecommended(
    ToggleRecommendedEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await toggleRecommendedUseCase(
      ToggleRecommendedParams(
        userId: event.userId,
        gameId: event.gameId,
      ),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (_) => emit(RecommendedToggled(event.gameId)),
    );
  }

  /// Updates top 3 games.
  Future<void> _onUpdateTopThree(
    UpdateTopThreeEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await updateTopThreeUseCase(
      UpdateTopThreeParams(
        userId: event.userId,
        gameIds: event.gameIds,
      ),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (_) => emit(TopThreeUpdated(event.gameIds)),
    );
  }

  /// Loads top 3 games.
  Future<void> _onLoadTopThree(
    LoadTopThreeEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await getTopThreeUseCase(
      GetTopThreeParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (games) {
        final gameIds = games.map((game) => game['id'] as int).toList();
        emit(TopThreeLoaded(gameIds));
      },
    );
  }

  /// Clears top 3 games.
  Future<void> _onClearTopThree(
    ClearTopThreeEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await clearTopThreeUseCase(
      ClearTopThreeParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (_) => emit(const TopThreeCleared()),
    );
  }

  /// Loads wishlisted games.
  Future<void> _onLoadWishlistedGames(
    LoadWishlistedGamesEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await getWishlistedGamesUseCase(
      GetWishlistedGamesParams(
        userId: event.userId,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (gameIds) => emit(WishlistedGamesLoaded(gameIds)),
    );
  }

  /// Loads rated games.
  Future<void> _onLoadRatedGames(
    LoadRatedGamesEvent event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    final result = await getRatedGamesUseCase(
      GetRatedGamesParams(
        userId: event.userId,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(CollectionError(failure.message)),
      (games) => emit(RatedGamesLoaded(games)),
    );
  }
}
