// presentation/blocs/user_game_data/user_game_data_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/usecases/collection/get_rated_games_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/get_recommended_games_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/get_top_three_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/get_wishlisted_games_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/rate_game_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/remove_from_top_three_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/remove_rating_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/set_top_three_game_at_position_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/toggle_recommended_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/toggle_wishlist_use_case.dart';
import 'package:gamer_grove/domain/usecases/collection/update_top_three_use_case.dart';

part 'user_game_data_event.dart';
part 'user_game_data_state.dart';

/// Global BLoC for managing user-game relationships
///
/// This BLoC serves as the single source of truth for all user-game data:
/// - Wishlist status
/// - Recommendations
/// - Game ratings
/// - Top three games
///
/// Usage:
/// ```dart
/// // Load user data (typically on app start or login)
/// context.read<UserGameDataBloc>().add(LoadUserGameDataEvent(userId));
///
/// // Toggle wishlist
/// context.read<UserGameDataBloc>().add(ToggleWishlistEvent(
///   userId: userId,
///   gameId: gameId,
/// ));
///
/// // Check status in any widget
/// final state = context.watch<UserGameDataBloc>().state;
/// if (state is UserGameDataLoaded) {
///   final isWishlisted = state.isWishlisted(gameId);
///   final rating = state.getRating(gameId);
/// }
/// ```
class UserGameDataBloc extends Bloc<UserGameDataEvent, UserGameDataState> {

  UserGameDataBloc({
    required this.getWishlistedGamesUseCase,
    required this.getRatedGamesUseCase,
    required this.getRecommendedGamesUseCase,
    required this.getTopThreeUseCase,
    required this.toggleWishlistUseCase,
    required this.toggleRecommendedUseCase,
    required this.rateGameUseCase,
    required this.removeRatingUseCase,
    required this.updateTopThreeUseCase,
    required this.setTopThreeGameAtPositionUseCase,
    required this.removeFromTopThreeUseCase,
  }) : super(const UserGameDataInitial()) {
    on<LoadUserGameDataEvent>(_onLoadUserGameData);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<ToggleRecommendationEvent>(_onToggleRecommendation);
    on<RateGameEvent>(_onRateGame);
    on<RemoveRatingEvent>(_onRemoveRating);
    on<UpdateTopThreeEvent>(_onUpdateTopThree);
    on<SetGameTopThreePositionEvent>(_onSetGameTopThreePosition);
    on<RemoveFromTopThreeEvent>(_onRemoveFromTopThree);
    on<ClearUserGameDataEvent>(_onClearUserGameData);
    on<RefreshUserGameDataEvent>(_onRefreshUserGameData);
  }
  final GetWishlistedGamesUseCase getWishlistedGamesUseCase;
  final GetRatedGamesUseCase getRatedGamesUseCase;
  final GetRecommendedGamesUseCase getRecommendedGamesUseCase;
  final GetTopThreeUseCase getTopThreeUseCase;
  final ToggleWishlistUseCase toggleWishlistUseCase;
  final ToggleRecommendedUseCase toggleRecommendedUseCase;
  final RateGameUseCase rateGameUseCase;
  final RemoveRatingUseCase removeRatingUseCase;
  final UpdateTopThreeUseCase updateTopThreeUseCase;
  final SetTopThreeGameAtPositionUseCase setTopThreeGameAtPositionUseCase;
  final RemoveFromTopThreeUseCase removeFromTopThreeUseCase;

  /// Load all user game data from backend
  Future<void> _onLoadUserGameData(
    LoadUserGameDataEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    emit(const UserGameDataLoading());

    try {
      // Load all user game data in parallel
      // ✅ FIX: Load ALL ratings/wishlist/recommendations with high limit (no pagination)
      final results = await Future.wait([
        getWishlistedGamesUseCase(
          GetWishlistedGamesParams(
              userId: event.userId, limit: 10000,), // All wishlist
        ),
        getRatedGamesUseCase(
          GetRatedGamesParams(
              userId: event.userId, limit: 10000,), // All ratings
        ),
        getRecommendedGamesUseCase(
          GetRecommendedGamesParams(
              userId: event.userId, limit: 10000,), // All recommendations
        ),
        getTopThreeUseCase(GetTopThreeParams(userId: event.userId)),
      ]);

      // Extract results
      final wishlistResult = results[0];
      final ratedResult = results[1];
      final recommendedResult = results[2];
      final topThreeResult = results[3];

      // Check for failures
      String? errorMessage;
      if (wishlistResult.isLeft()) {
        wishlistResult.fold((l) {
          errorMessage = l.message;
        }, (r) => null,);
      }
      if (ratedResult.isLeft()) {
        ratedResult.fold((l) {
          errorMessage = l.message;
        }, (r) => null,);
      }
      if (recommendedResult.isLeft()) {
        recommendedResult.fold((l) {
          errorMessage = l.message;
        }, (r) => null,);
      }
      if (topThreeResult.isLeft()) {
        topThreeResult.fold((l) {
          errorMessage = l.message;
        }, (r) => null,);
      }

      if (errorMessage != null) {
        emit(UserGameDataError(errorMessage!));
        return;
      }

      // Extract data
      final wishlistedGameIds = <int>{};
      wishlistResult.fold(
        (l) => null,
        (gameIds) {
          if (gameIds is List<int>) {
            wishlistedGameIds.addAll(gameIds);
          } else {}
        },
      );

      final ratedGames = <int, double>{};
      ratedResult.fold(
        (l) => null,
        (games) {
          if (games is List<Map<String, dynamic>>) {
            for (final game in games) {
              final gameId = game['game_id'] as int;
              final rating = (game['rating'] as num).toDouble();
              ratedGames[gameId] = rating;
            }
          } else {}
        },
      );

      final recommendedGameIds = <int>{};
      recommendedResult.fold(
        (l) => null,
        (gameIds) {
          if (gameIds is List<int>) {
            recommendedGameIds.addAll(gameIds);
          } else {}
        },
      );

      final topThreeGameIds = <int>[];
      topThreeResult.fold(
        (l) => null,
        (games) {
          if (games is List<Map<String, dynamic>>) {
            for (final game in games) {
              final gameId = game['game_id'] as int;
              topThreeGameIds.add(gameId);
            }
          } else {}
        },
      );

      emit(UserGameDataLoaded(
        userId: event.userId,
        wishlistedGameIds: wishlistedGameIds,
        recommendedGameIds: recommendedGameIds,
        ratedGames: ratedGames,
        topThreeGameIds: topThreeGameIds,
      ),);
    } on Exception catch (e) {
      emit(UserGameDataError('Failed to load user game data: $e'));
    }
  }

  /// Toggle wishlist for a game
  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserGameDataLoaded) return;

    // Optimistic update
    final updatedWishlist = Set<int>.from(currentState.wishlistedGameIds);
    final isNowWishlisted = !updatedWishlist.contains(event.gameId);

    if (isNowWishlisted) {
      updatedWishlist.add(event.gameId);
    } else {
      updatedWishlist.remove(event.gameId);
    }

    emit(WishlistToggled(
      gameId: event.gameId,
      isNowWishlisted: isNowWishlisted,
      userId: currentState.userId,
      wishlistedGameIds: updatedWishlist,
      recommendedGameIds: currentState.recommendedGameIds,
      ratedGames: currentState.ratedGames,
      topThreeGameIds: currentState.topThreeGameIds,
    ),);

    // Backend update
    final result = await toggleWishlistUseCase(
      ToggleWishlistParams(
        userId: event.userId,
        gameId: event.gameId,
      ),
    );

    result.fold(
      (failure) {
        // Revert on error
        emit(currentState);
        emit(UserGameDataError(failure.message));
      },
      (_) {
        // Success - state already updated
      },
    );
  }

  /// Toggle recommendation for a game
  Future<void> _onToggleRecommendation(
    ToggleRecommendationEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserGameDataLoaded) {
      return;
    }

    // Optimistic update
    final updatedRecommendations =
        Set<int>.from(currentState.recommendedGameIds);
    final isNowRecommended = !updatedRecommendations.contains(event.gameId);

    if (isNowRecommended) {
      updatedRecommendations.add(event.gameId);
    } else {
      updatedRecommendations.remove(event.gameId);
    }

    emit(RecommendationToggled(
      gameId: event.gameId,
      isNowRecommended: isNowRecommended,
      userId: currentState.userId,
      wishlistedGameIds: currentState.wishlistedGameIds,
      recommendedGameIds: updatedRecommendations,
      ratedGames: currentState.ratedGames,
      topThreeGameIds: currentState.topThreeGameIds,
    ),);

    // Backend update
    final result = await toggleRecommendedUseCase(
      ToggleRecommendedParams(
        userId: event.userId,
        gameId: event.gameId,
      ),
    );

    result.fold(
      (failure) {
        // Revert on error
        emit(currentState);
        emit(UserGameDataError(failure.message));
      },
      (_) {
        // Success - state already updated
      },
    );
  }

  /// Rate a game
  Future<void> _onRateGame(
    RateGameEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserGameDataLoaded) return;

    // Optimistic update
    final updatedRatings = Map<int, double>.from(currentState.ratedGames);
    updatedRatings[event.gameId] = event.rating;

    emit(GameRated(
      gameId: event.gameId,
      rating: event.rating,
      userId: currentState.userId,
      wishlistedGameIds: currentState.wishlistedGameIds,
      recommendedGameIds: currentState.recommendedGameIds,
      ratedGames: updatedRatings,
      topThreeGameIds: currentState.topThreeGameIds,
    ),);

    // Backend update
    final result = await rateGameUseCase(
      RateGameParams(
        userId: event.userId,
        gameId: event.gameId,
        rating: event.rating,
      ),
    );

    result.fold(
      (failure) {
        // Revert on error
        emit(currentState);
        emit(UserGameDataError(failure.message));
      },
      (_) {
        // Success - state already updated
      },
    );
  }

  /// Remove rating from a game
  Future<void> _onRemoveRating(
    RemoveRatingEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserGameDataLoaded) return;

    // Optimistic update
    final updatedRatings = Map<int, double>.from(currentState.ratedGames);
    updatedRatings.remove(event.gameId);

    emit(RatingRemoved(
      gameId: event.gameId,
      userId: currentState.userId,
      wishlistedGameIds: currentState.wishlistedGameIds,
      recommendedGameIds: currentState.recommendedGameIds,
      ratedGames: updatedRatings,
      topThreeGameIds: currentState.topThreeGameIds,
    ),);

    // Backend update
    final result = await removeRatingUseCase(
      RemoveRatingParams(
        userId: event.userId,
        gameId: event.gameId,
      ),
    );

    result.fold(
      (failure) {
        // Revert on error
        emit(currentState);
        emit(UserGameDataError(failure.message));
      },
      (_) {
        // Success - state already updated
      },
    );
  }

  /// Update top three games
  Future<void> _onUpdateTopThree(
    UpdateTopThreeEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserGameDataLoaded) return;

    // Optimistic update
    emit(TopThreeUpdated(
      userId: currentState.userId,
      wishlistedGameIds: currentState.wishlistedGameIds,
      recommendedGameIds: currentState.recommendedGameIds,
      ratedGames: currentState.ratedGames,
      topThreeGameIds: List.from(event.gameIds),
    ),);

    // Backend update
    final result = await updateTopThreeUseCase(
      UpdateTopThreeParams(
        userId: event.userId,
        gameIds: event.gameIds,
      ),
    );

    result.fold(
      (failure) {
        // Revert on error
        emit(currentState);
        emit(UserGameDataError(failure.message));
      },
      (_) {
        // Success - state already updated
      },
    );
  }

  /// Remove a game from top three
  Future<void> _onRemoveFromTopThree(
    RemoveFromTopThreeEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserGameDataLoaded) return;

    // Backend update
    final result = await removeFromTopThreeUseCase(
      RemoveFromTopThreeParams(
        userId: event.userId,
        gameId: event.gameId,
      ),
    );

    // ✅ Handle result BEFORE returning (not in async callback)
    await result.fold(
      (failure) async {
        emit(UserGameDataError(failure.message));
      },
      (_) async {
        // Reload top three from backend to get the correct state
        final topThreeResult = await getTopThreeUseCase(
          GetTopThreeParams(userId: event.userId),
        );

        topThreeResult.fold(
          (failure) {},
          (games) {
            final topThreeGameIds = <int>[];
            for (final game in games) {
              final gameId = game['game_id'] as int;
              topThreeGameIds.add(gameId);
            }

            emit(TopThreeUpdated(
              userId: currentState.userId,
              wishlistedGameIds: currentState.wishlistedGameIds,
              recommendedGameIds: currentState.recommendedGameIds,
              ratedGames: currentState.ratedGames,
              topThreeGameIds: topThreeGameIds,
            ),);
          },
        );
      },
    );
  }

  /// Set a game at a specific position in top three
  Future<void> _onSetGameTopThreePosition(
    SetGameTopThreePositionEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserGameDataLoaded) return;

    // Backend update first (it handles the logic correctly)
    final result = await setTopThreeGameAtPositionUseCase(
      SetTopThreeGameAtPositionParams(
        userId: event.userId,
        gameId: event.gameId,
        position: event.position,
      ),
    );

    // ✅ Handle result BEFORE returning (not in async callback)
    await result.fold(
      (failure) async {
        emit(UserGameDataError(failure.message));
      },
      (_) async {
        // Reload top three from backend to get the correct state
        final topThreeResult = await getTopThreeUseCase(
          GetTopThreeParams(userId: event.userId),
        );

        topThreeResult.fold(
          (failure) {},
          (games) {
            final topThreeGameIds = <int>[];
            for (final game in games) {
              final gameId = game['game_id'] as int;
              topThreeGameIds.add(gameId);
            }

            emit(TopThreeUpdated(
              userId: currentState.userId,
              wishlistedGameIds: currentState.wishlistedGameIds,
              recommendedGameIds: currentState.recommendedGameIds,
              ratedGames: currentState.ratedGames,
              topThreeGameIds: topThreeGameIds,
            ),);
          },
        );
      },
    );
  }

  /// Clear user game data (e.g., on logout)
  Future<void> _onClearUserGameData(
    ClearUserGameDataEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    emit(const UserGameDataInitial());
  }

  /// Refresh user game data from backend
  Future<void> _onRefreshUserGameData(
    RefreshUserGameDataEvent event,
    Emitter<UserGameDataState> emit,
  ) async {
    // Don't show loading state on refresh, reuse same logic as load
    try {
      // ✅ FIX: Load ALL data with high limit (same as LoadUserGameDataEvent)
      final results = await Future.wait([
        getWishlistedGamesUseCase(
          GetWishlistedGamesParams(userId: event.userId, limit: 10000),
        ),
        getRatedGamesUseCase(
          GetRatedGamesParams(userId: event.userId, limit: 10000),
        ),
        getRecommendedGamesUseCase(
          GetRecommendedGamesParams(userId: event.userId, limit: 10000),
        ),
        getTopThreeUseCase(GetTopThreeParams(userId: event.userId)),
      ]);

      final wishlistResult = results[0];
      final ratedResult = results[1];
      final recommendedResult = results[2];
      final topThreeResult = results[3];

      String? errorMessage;
      if (wishlistResult.isLeft()) {
        wishlistResult.fold((l) => errorMessage = l.message, (r) => null);
      }
      if (ratedResult.isLeft()) {
        ratedResult.fold((l) => errorMessage = l.message, (r) => null);
      }
      if (recommendedResult.isLeft()) {
        recommendedResult.fold((l) => errorMessage = l.message, (r) => null);
      }
      if (topThreeResult.isLeft()) {
        topThreeResult.fold((l) => errorMessage = l.message, (r) => null);
      }

      if (errorMessage != null) {
        emit(UserGameDataError(errorMessage!));
        return;
      }

      final wishlistedGameIds = <int>{};
      wishlistResult.fold(
        (l) => null,
        (r) {
          final gameIds = r as List<int>;
          wishlistedGameIds.addAll(gameIds);
        },
      );

      final ratedGames = <int, double>{};
      ratedResult.fold(
        (l) => null,
        (r) {
          final games = r as List<Map<String, dynamic>>;
          for (final game in games) {
            final gameId = game['game_id'] as int;
            final rating = (game['rating'] as num).toDouble();
            ratedGames[gameId] = rating;
          }
        },
      );

      final recommendedGameIds = <int>{};
      recommendedResult.fold(
        (l) => null,
        (r) {
          final gameIds = r as List<int>;
          recommendedGameIds.addAll(gameIds);
        },
      );

      final topThreeGameIds = <int>[];
      topThreeResult.fold(
        (l) => null,
        (r) {
          final games = r as List<Map<String, dynamic>>;
          for (final game in games) {
            final gameId = game['game_id'] as int;
            topThreeGameIds.add(gameId);
          }
        },
      );

      emit(UserGameDataLoaded(
        userId: event.userId,
        wishlistedGameIds: wishlistedGameIds,
        recommendedGameIds: recommendedGameIds,
        ratedGames: ratedGames,
        topThreeGameIds: topThreeGameIds,
      ),);
    } on Exception catch (e) {
      emit(UserGameDataError('Failed to refresh user game data: $e'));
    }
  }
}
