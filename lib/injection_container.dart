// lib/injection_container.dart

/// Dependency Injection Container using GetIt.
///
/// Registers all dependencies for the app following Clean Architecture.
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gamer_grove/core/constants/api_constants.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import 'package:gamer_grove/domain/usecases/auth/get_current_user.dart';
import 'package:gamer_grove/domain/usecases/auth/is_authenticated.dart';
import 'package:gamer_grove/domain/usecases/auth/reset_password.dart';
import 'package:gamer_grove/domain/usecases/auth/sign_in.dart';
import 'package:gamer_grove/domain/usecases/auth/sign_out.dart';
import 'package:gamer_grove/domain/usecases/auth/sign_up.dart';
import 'package:gamer_grove/domain/usecases/auth/update_password.dart';
import 'package:gamer_grove/domain/usecases/characters/get_character_with_games.dart';
import 'package:gamer_grove/domain/usecases/event/get_complete_event_details.dart';
import 'package:gamer_grove/domain/usecases/event/get_current_events.dart';
import 'package:gamer_grove/domain/usecases/event/get_event_details.dart';
import 'package:gamer_grove/domain/usecases/event/get_events_by_date_range.dart';
import 'package:gamer_grove/domain/usecases/event/get_events_by_games.dart';
import 'package:gamer_grove/domain/usecases/event/get_upcoming_events.dart';
import 'package:gamer_grove/domain/usecases/event/search_events.dart';
import 'package:gamer_grove/domain/usecases/platform/get_platform_with_games.dart';
import 'package:gamer_grove/domain/usecases/user/follow_user.dart';
import 'package:gamer_grove/domain/usecases/user/get_user_followers.dart';
import 'package:gamer_grove/domain/usecases/user/get_user_following.dart';
import 'package:gamer_grove/domain/usecases/user/get_user_profile.dart';
import 'package:gamer_grove/domain/usecases/user/unfollow_user.dart';
import 'package:gamer_grove/domain/usecases/user/update_user_avatar.dart';
import 'package:gamer_grove/domain/usecases/user/update_user_profile.dart';
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
import 'package:gamer_grove/domain/usecases/game/get_game_details.dart';
import 'package:gamer_grove/domain/usecases/game/get_game_dlcs.dart';
import 'package:gamer_grove/domain/usecases/game/get_game_expansions.dart';
import 'package:gamer_grove/domain/usecases/game/get_latest_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_popular_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_similar_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_top_rated_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_upcoming_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_rated.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_recommendations.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_top_three.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_wishlist.dart';
import 'package:gamer_grove/domain/usecases/game/rate_game.dart';
import 'package:gamer_grove/domain/usecases/game/search_games.dart';
import 'package:gamer_grove/domain/usecases/game/toggle_recommend.dart';
import 'package:gamer_grove/domain/usecases/game/toggle_wishlist.dart';
import 'package:gamer_grove/domain/usecases/game_details/get_complete_game_details_page_data.dart';
import 'package:gamer_grove/domain/usecases/game_details/get_enhanced_game_details.dart';
import 'package:gamer_grove/domain/usecases/user/add_to_top_three.dart';
import 'package:gamer_grove/domain/usecases/user/remove_from_top_three.dart';
import 'package:gamer_grove/domain/usecases/user/get_user_top_three.dart';
import 'package:gamer_grove/presentation/blocs/character/character_bloc.dart';
import 'package:gamer_grove/presentation/blocs/event/event_bloc.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_bloc.dart';
import 'package:gamer_grove/presentation/blocs/user/user_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import 'core/network/network_info.dart';
// Data Layer - Data Sources
import 'package:gamer_grove/data/datasources/remote/igdb/igdb_datasource.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/igdb_datasource_impl.dart';
import 'data/datasources/remote/supabase/supabase_auth_datasource.dart';
import 'data/datasources/remote/supabase/supabase_auth_datasource_impl.dart';
import 'data/datasources/remote/supabase/supabase_user_datasource.dart';
import 'data/datasources/remote/supabase/supabase_user_datasource_impl.dart';
// Data Layer - Repositories
import 'data/repositories/auth_repository_impl.dart';
import 'package:gamer_grove/data/repositories/game_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/event_repository_impl.dart';
// Domain Layer - Repositories (Interfaces)
import 'domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/event_repository.dart';
// Presentation Layer - BLoCs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/collection/collection_bloc.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';

/// Service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies.
///
/// This should be called in main() before runApp().
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initDependencies();
///   runApp(MyApp());
/// }
/// ```
Future<void> initDependencies() async {
  // ============================================================
  // EXTERNAL DEPENDENCIES
  // ============================================================

  // Initialize Supabase
  final supabase = await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  sl
    ..registerLazySingleton<SupabaseClient>(() => supabase.client)

    // ============================================================
    // CORE
    // ============================================================

    // Register Connectivity first (required by NetworkInfo)
    ..registerLazySingleton<Connectivity>(() => Connectivity())
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl()),
    )
    ..registerLazySingleton<GameEnrichmentService>(
      () => GameEnrichmentService(
        supabase: sl(),
        enableLogging: true, // Enable logging to debug enrichment
      ),
    )

    // ============================================================
    // PRESENTATION LAYER - BLOCS
    // ============================================================

    // Auth BLoC
    ..registerFactory(
      () => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        resetPasswordUseCase: sl(),
        updatePasswordUseCase: sl(),
        isAuthenticatedUseCase: sl(),
      ),
    )

    // User Profile BLoC
    ..registerFactory(
      () => UserProfileBloc(
        getUserProfileUseCase: sl(),
        updateUserProfileUseCase: sl(),
        updateUserAvatarUseCase: sl(),
        followUserUseCase: sl(),
        unfollowUserUseCase: sl(),
        getFollowersUseCase: sl(),
        getFollowingUseCase: sl(),
      ),
    )

    // Collection BLoC
    ..registerFactory(
      () => CollectionBloc(
        getUserGameDataUseCase: sl(),
        rateGameUseCase: sl(),
        removeRatingUseCase: sl(),
        toggleWishlistUseCase: sl(),
        toggleRecommendedUseCase: sl(),
        updateTopThreeUseCase: sl(),
        getTopThreeUseCase: sl(),
        clearTopThreeUseCase: sl(),
        getWishlistedGamesUseCase: sl(),
        getRatedGamesUseCase: sl(),
      ),
    )

    // Game BLoC
    ..registerFactory(
      () => GameBloc(
        searchGames: sl(),
        getGameDetails: sl(),
        rateGame: sl(),
        toggleWishlist: sl(),
        toggleRecommend: sl(),
        addToTopThree: sl(),
        getPopularGames: sl(),
        getUpcomingGames: sl(),
        getLatestGames: sl(),
        getTopRatedGames: sl(),
        getUserWishlist: sl(),
        getUserRecommendations: sl(),
        getUserTopThreeGames: sl(),
        getUserTopThree: sl(),
        getUserRated: sl(),
        getSimilarGames: sl(),
        getGameDLCs: sl(),
        getGameExpansions: sl(),
        getEnhancedGameDetails: sl(),
        getCompleteGameDetailPageData: sl(),
        gameRepository: sl(),
        enrichmentService: sl(),
        removeFromTopThree: sl(),
      ),
    )
    ..registerFactory(
      () => CharacterBloc(
        getCharacterWithGames: sl(),
        enrichmentService: sl(),
      ),
    )
    ..registerFactory(
      () => EventBloc(
        enrichmentService: sl(),
        getEventDetails: sl(),
        getCurrentEvents: sl(),
        getUpcomingEvents: sl(),
        searchEvents: sl(),
        getEventsByDateRange: sl(),
        getEventsByGames: sl(),
        getCompleteEventDetails: sl(),
      ),
    )
    ..registerFactory(
      () => PlatformBloc(
        enrichmentService: sl(),
        gameRepository: sl(),
        getPlatformWithGames: sl(),
      ),
    )
    // ============================================================
    // DOMAIN LAYER - USE CASES
    // ============================================================

    // Auth Use Cases
    ..registerLazySingleton(() => SignInUseCase(sl()))
    ..registerLazySingleton(() => SignUpUseCase(sl()))
    ..registerLazySingleton(() => SignOutUseCase(sl()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl()))
    ..registerLazySingleton(() => ResetPasswordUseCase(sl()))
    ..registerLazySingleton(() => UpdatePasswordUseCase(sl()))
    ..registerLazySingleton(() => IsAuthenticatedUseCase(sl()))

    // User Profile Use Cases
    ..registerLazySingleton(() => GetUserProfileUseCase(sl()))
    ..registerLazySingleton(() => UpdateUserProfileUseCase(sl()))
    ..registerLazySingleton(() => UpdateUserAvatarUseCase(sl()))
    ..registerLazySingleton(() => FollowUserUseCase(sl()))
    ..registerLazySingleton(() => UnfollowUserUseCase(sl()))
    ..registerLazySingleton(() => GetFollowersUseCase(sl()))
    ..registerLazySingleton(() => GetFollowingUseCase(sl()))

    // Collection Use Cases
    ..registerLazySingleton(() => GetUserGameDataUseCase(sl()))
    ..registerLazySingleton(() => RateGameUseCase(sl()))
    ..registerLazySingleton(() => RemoveRatingUseCase(sl()))
    ..registerLazySingleton(() => ToggleWishlistUseCase(sl()))
    ..registerLazySingleton(() => ToggleRecommendedUseCase(sl()))
    ..registerLazySingleton(() => UpdateTopThreeUseCase(sl()))
    ..registerLazySingleton(() => GetTopThreeUseCase(sl()))
    ..registerLazySingleton(() => ClearTopThreeUseCase(sl()))
    ..registerLazySingleton(() => GetWishlistedGamesUseCase(sl()))
    ..registerLazySingleton(() => GetRatedGamesUseCase(sl()))

    // Game Use Cases
    ..registerLazySingleton(() => SearchGames(sl()))
    ..registerLazySingleton(() => GetGameDetails(sl()))
    ..registerLazySingleton(() => RateGame(sl()))
    ..registerLazySingleton(() => ToggleWishlist(sl()))
    ..registerLazySingleton(() => ToggleRecommend(sl()))
    ..registerLazySingleton(() => AddToTopThree(sl()))
    ..registerLazySingleton(() => RemoveFromTopThree(sl()))
    ..registerLazySingleton(() => GetPopularGames(sl()))
    ..registerLazySingleton(() => GetUpcomingGames(sl()))
    ..registerLazySingleton(() => GetLatestGames(sl()))
    ..registerLazySingleton(() => GetTopRatedGames(sl()))
    ..registerLazySingleton(() => GetUserWishlist(sl()))
    ..registerLazySingleton(() => GetUserRecommendations(sl()))
    ..registerLazySingleton(() => GetUserTopThreeGames(sl()))
    ..registerLazySingleton(() => GetUserTopThree(sl()))
    ..registerLazySingleton(() => GetUserRated(sl()))
    ..registerLazySingleton(() => GetSimilarGames(sl()))
    ..registerLazySingleton(() => GetGameDLCs(sl()))
    ..registerLazySingleton(() => GetGameExpansions(sl()))
    ..registerLazySingleton(() => GetEnhancedGameDetails(sl()))
    ..registerLazySingleton(
        () => GetCompleteGameDetailPageData(getEnhancedGameDetails: sl()))

    //Character Use Cases
    ..registerLazySingleton(() => GetCharacterWithGames(sl()))

    // Event Use Cases
    ..registerLazySingleton(() => GetEventDetails(sl()))
    ..registerLazySingleton(() => GetCurrentEvents(sl()))
    ..registerLazySingleton(() => GetUpcomingEvents(sl()))
    ..registerLazySingleton(() => SearchEvents(sl()))
    ..registerLazySingleton(() => GetEventsByDateRange(sl()))
    ..registerLazySingleton(() => GetEventsByGames(sl()))
    ..registerLazySingleton(() =>
        GetCompleteEventDetails(eventRepository: sl(), gameRepository: sl()))

    // Platform Use Cases
    ..registerLazySingleton(() => GetPlatformWithGames(sl()))

    // ============================================================
    // DATA LAYER - REPOSITORIES
    // ============================================================

    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authDataSource: sl(),
        supabase: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        userDataSource: sl(),
        supabase: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerLazySingleton<EventRepository>(
      () => EventRepositoryImpl(
        igdbDataSource: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerLazySingleton<GameRepository>(
      () => GameRepositoryImpl(
        igdbDataSource: sl(),
        networkInfo: sl(),
        supabaseUserDataSource: sl(),
        enrichmentService: sl(),
      ),
    )

    // ============================================================
    // DATA LAYER - DATA SOURCES
    // ============================================================

    ..registerLazySingleton<SupabaseAuthDataSource>(
      () => SupabaseAuthDataSourceImpl(supabase: sl()),
    )
    ..registerLazySingleton<SupabaseUserDataSource>(
      () => SupabaseUserDataSourceImpl(supabase: sl()),
    )

    // IGDB Data Source
    ..registerLazySingleton<IgdbDataSource>(
      () => IgdbDataSourceImpl(dio: sl()),
    )

    // Dio HTTP client
    ..registerLazySingleton<Dio>(() {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      return dio;
    });
}

/// Resets all dependencies.
///
/// Useful for testing or hot reload.
///
/// Example:
/// ```dart
/// await resetDependencies();
/// await initDependencies();
/// ```
Future<void> resetDependencies() async {
  await sl.reset();
}
