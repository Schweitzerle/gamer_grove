import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
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
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetWishlistedGames extends Mock
    implements GetWishlistedGamesUseCase {}

class _MockGetRatedGames extends Mock implements GetRatedGamesUseCase {}

class _MockGetRecommendedGames extends Mock
    implements GetRecommendedGamesUseCase {}

class _MockGetTopThree extends Mock implements GetTopThreeUseCase {}

class _MockToggleWishlist extends Mock implements ToggleWishlistUseCase {}

class _MockToggleRecommended extends Mock implements ToggleRecommendedUseCase {}

class _MockRateGame extends Mock implements RateGameUseCase {}

class _MockRemoveRating extends Mock implements RemoveRatingUseCase {}

class _MockUpdateTopThree extends Mock implements UpdateTopThreeUseCase {}

class _MockSetTopThreePosition extends Mock
    implements SetTopThreeGameAtPositionUseCase {}

class _MockRemoveFromTopThree extends Mock
    implements RemoveFromTopThreeUseCase {}

/// Records tracked event names for asserting the funnel wiring.
class _RecordingAnalytics implements AnalyticsService {
  final List<String> tracked = [];

  @override
  Future<void> track(String name, {Map<String, Object?>? properties}) async {
    tracked.add(name);
  }

  @override
  Future<void> screen(String screenName) async {}
}

void main() {
  late _MockToggleWishlist toggleWishlist;
  late _MockRateGame rateGame;
  late _RecordingAnalytics analytics;

  const userId = 'user-1';
  const gameId = 42;

  setUpAll(() {
    registerFallbackValue(
      const ToggleWishlistParams(userId: userId, gameId: gameId),
    );
    registerFallbackValue(
      const RateGameParams(userId: userId, gameId: gameId, rating: 9),
    );
  });

  setUp(() {
    toggleWishlist = _MockToggleWishlist();
    rateGame = _MockRateGame();
    analytics = _RecordingAnalytics();
  });

  UserGameDataBloc buildBloc() => UserGameDataBloc(
        getWishlistedGamesUseCase: _MockGetWishlistedGames(),
        getRatedGamesUseCase: _MockGetRatedGames(),
        getRecommendedGamesUseCase: _MockGetRecommendedGames(),
        getTopThreeUseCase: _MockGetTopThree(),
        toggleWishlistUseCase: toggleWishlist,
        toggleRecommendedUseCase: _MockToggleRecommended(),
        rateGameUseCase: rateGame,
        removeRatingUseCase: _MockRemoveRating(),
        updateTopThreeUseCase: _MockUpdateTopThree(),
        setTopThreeGameAtPositionUseCase: _MockSetTopThreePosition(),
        removeFromTopThreeUseCase: _MockRemoveFromTopThree(),
        analytics: analytics,
      );

  UserGameDataLoaded loadedState({
    Set<int> wishlisted = const {},
    Map<int, double> rated = const {},
  }) =>
      UserGameDataLoaded(
        userId: userId,
        wishlistedGameIds: wishlisted,
        recommendedGameIds: const {},
        ratedGames: rated,
        topThreeGameIds: const [],
      );

  group('RateGameEvent', () {
    blocTest<UserGameDataBloc, UserGameDataState>(
      'emits GameRated and tracks rate_game on success',
      setUp: () => when(() => rateGame(any()))
          .thenAnswer((_) async => const Right(null)),
      build: buildBloc,
      seed: loadedState,
      act: (bloc) => bloc.add(
        const RateGameEvent(userId: userId, gameId: gameId, rating: 9),
      ),
      expect: () => [
        isA<GameRated>()
            .having((s) => s.gameId, 'gameId', gameId)
            .having((s) => s.rating, 'rating', 9)
            .having((s) => s.ratedGames[gameId], 'stored rating', 9),
      ],
      verify: (_) {
        expect(analytics.tracked, contains(AnalyticsEvents.rateGame));
      },
    );

    blocTest<UserGameDataBloc, UserGameDataState>(
      'reverts to the previous state and does not track on failure',
      setUp: () => when(() => rateGame(any())).thenAnswer(
        (_) async => const Left(ServerFailure()),
      ),
      build: buildBloc,
      seed: loadedState,
      act: (bloc) => bloc.add(
        const RateGameEvent(userId: userId, gameId: gameId, rating: 9),
      ),
      expect: () => [
        isA<GameRated>(), // optimistic update
        isA<UserGameDataLoaded>(), // revert
        isA<UserGameDataError>(),
      ],
      verify: (_) {
        expect(analytics.tracked, isNot(contains(AnalyticsEvents.rateGame)));
      },
    );
  });

  group('ToggleWishlistEvent', () {
    blocTest<UserGameDataBloc, UserGameDataState>(
      'tracks wishlist_add when a game is added',
      setUp: () => when(() => toggleWishlist(any()))
          .thenAnswer((_) async => const Right(null)),
      build: buildBloc,
      seed: loadedState,
      act: (bloc) =>
          bloc.add(const ToggleWishlistEvent(userId: userId, gameId: gameId)),
      expect: () => [
        isA<WishlistToggled>()
            .having((s) => s.isNowWishlisted, 'isNowWishlisted', true),
      ],
      verify: (_) {
        expect(analytics.tracked, contains(AnalyticsEvents.wishlistAdd));
      },
    );

    blocTest<UserGameDataBloc, UserGameDataState>(
      'does NOT track wishlist_add when a game is removed',
      setUp: () => when(() => toggleWishlist(any()))
          .thenAnswer((_) async => const Right(null)),
      build: buildBloc,
      seed: () => loadedState(wishlisted: {gameId}),
      act: (bloc) =>
          bloc.add(const ToggleWishlistEvent(userId: userId, gameId: gameId)),
      expect: () => [
        isA<WishlistToggled>()
            .having((s) => s.isNowWishlisted, 'isNowWishlisted', false),
      ],
      verify: (_) {
        expect(
          analytics.tracked,
          isNot(contains(AnalyticsEvents.wishlistAdd)),
        );
      },
    );
  });
}
