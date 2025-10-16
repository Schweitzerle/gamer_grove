// lib/injection_container.dart

/// Dependency Injection Container using GetIt.
///
/// Registers all dependencies for the app following Clean Architecture.
library;

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
import 'package:gamer_grove/presentation/blocs/user/user_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import 'core/network/network_info.dart';
// Data Layer - Data Sources
import 'data/datasources/remote/supabase/supabase_auth_datasource.dart';
import 'data/datasources/remote/supabase/supabase_auth_datasource_impl.dart';
import 'data/datasources/remote/supabase/supabase_user_datasource.dart';
import 'data/datasources/remote/supabase/supabase_user_datasource_impl.dart';
// Data Layer - Repositories
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
// Domain Layer - Repositories (Interfaces)
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/user_repository.dart';
// Presentation Layer - BLoCs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/collection/collection_bloc.dart';

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
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'YOUR_SUPABASE_URL',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'YOUR_SUPABASE_ANON_KEY',
    ),
  );

  sl.registerLazySingleton<SupabaseClient>(() => supabase.client);

  // ============================================================
  // CORE
  // ============================================================

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

  // ============================================================
  // DATA LAYER - DATA SOURCES
  // ============================================================

  sl.registerLazySingleton<SupabaseAuthDataSource>(
    () => SupabaseAuthDataSourceImpl(supabase: sl()),
  );

  sl.registerLazySingleton<SupabaseUserDataSource>(
    () => SupabaseUserDataSourceImpl(supabase: sl()),
  );
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
