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
import 'package:gamer_grove/domain/usecases/user/get_user_top_three.dart';
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
// Domain Layer - Repositories (Interfaces)
import 'domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'domain/repositories/user_repository.dart';
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

  sl.registerLazySingleton<SupabaseClient>(() => supabase.client);

  // ============================================================
  // CORE
  // ============================================================

  // Register Connectivity first (required by NetworkInfo)
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  sl.registerLazySingleton<GameEnrichmentService>(
    () => GameEnrichmentService(supabase: sl()),
  );

  // ============================================================
  // PRESENTATION LAYER - BLOCS
  // ============================================================

  // Auth BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      resetPasswordUseCase: sl(),
      updatePasswordUseCase: sl(),
      isAuthenticatedUseCase: sl(),
    ),
  );

  // User Profile BLoC
  sl.registerFactory(
    () => UserProfileBloc(
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
      updateUserAvatarUseCase: sl(),
      followUserUseCase: sl(),
      unfollowUserUseCase: sl(),
      getFollowersUseCase: sl(),
      getFollowingUseCase: sl(),
    ),
  );

  // Collection BLoC
  sl.registerFactory(
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
  );

  // Game BLoC
  sl.registerFactory(
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
    ),
  );

  // ============================================================
  // DOMAIN LAYER - USE CASES
  // ============================================================

  // Auth Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));
  sl.registerLazySingleton(() => IsAuthenticatedUseCase(sl()));

  // User Profile Use Cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserAvatarUseCase(sl()));
  sl.registerLazySingleton(() => FollowUserUseCase(sl()));
  sl.registerLazySingleton(() => UnfollowUserUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowersUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowingUseCase(sl()));

  // Collection Use Cases
  sl.registerLazySingleton(() => GetUserGameDataUseCase(sl()));
  sl.registerLazySingleton(() => RateGameUseCase(sl()));
  sl.registerLazySingleton(() => RemoveRatingUseCase(sl()));
  sl.registerLazySingleton(() => ToggleWishlistUseCase(sl()));
  sl.registerLazySingleton(() => ToggleRecommendedUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTopThreeUseCase(sl()));
  sl.registerLazySingleton(() => GetTopThreeUseCase(sl()));
  sl.registerLazySingleton(() => ClearTopThreeUseCase(sl()));
  sl.registerLazySingleton(() => GetWishlistedGamesUseCase(sl()));
  sl.registerLazySingleton(() => GetRatedGamesUseCase(sl()));

  // Game Use Cases
  sl.registerLazySingleton(() => SearchGames(sl()));
  sl.registerLazySingleton(() => GetGameDetails(sl()));
  sl.registerLazySingleton(() => RateGame(sl()));
  sl.registerLazySingleton(() => ToggleWishlist(sl()));
  sl.registerLazySingleton(() => ToggleRecommend(sl()));
  sl.registerLazySingleton(() => AddToTopThree(sl()));
  sl.registerLazySingleton(() => GetPopularGames(sl()));
  sl.registerLazySingleton(() => GetUpcomingGames(sl()));
  sl.registerLazySingleton(() => GetLatestGames(sl()));
  sl.registerLazySingleton(() => GetTopRatedGames(sl()));
  sl.registerLazySingleton(() => GetUserWishlist(sl()));
  sl.registerLazySingleton(() => GetUserRecommendations(sl()));
  sl.registerLazySingleton(() => GetUserTopThreeGames(sl()));
  sl.registerLazySingleton(() => GetUserTopThree(sl()));
  sl.registerLazySingleton(() => GetUserRated(sl()));
  sl.registerLazySingleton(() => GetSimilarGames(sl()));
  sl.registerLazySingleton(() => GetGameDLCs(sl()));
  sl.registerLazySingleton(() => GetGameExpansions(sl()));
  sl.registerLazySingleton(() => GetEnhancedGameDetails(sl()));
  sl.registerLazySingleton(
      () => GetCompleteGameDetailPageData(getEnhancedGameDetails: sl()));

  // ============================================================
  // DATA LAYER - REPOSITORIES
  // ============================================================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authDataSource: sl(),
      supabase: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      userDataSource: sl(),
      supabase: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(
      igdbDataSource: sl(),
      networkInfo: sl(),
      supabaseUserDataSource: sl(),
      enrichmentService: sl(),
    ),
  );

  // ============================================================
  // DATA LAYER - DATA SOURCES
  // ============================================================

  sl.registerLazySingleton<SupabaseAuthDataSource>(
    () => SupabaseAuthDataSourceImpl(supabase: sl()),
  );

  sl.registerLazySingleton<SupabaseUserDataSource>(
    () => SupabaseUserDataSourceImpl(supabase: sl()),
  );

  // IGDB Data Source
  sl.registerLazySingleton<IgdbDataSource>(
    () => IgdbDataSourceImpl(dio: sl()),
  );

  // Dio HTTP client
  sl.registerLazySingleton<Dio>(() {
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
