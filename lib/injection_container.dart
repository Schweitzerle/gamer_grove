// lib/injection_container.dart
import 'package:gamer_grove/domain/usecases/game/getUserRated.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Import all your classes here
import 'data/datasources/local/cache_datasource.dart';
import 'data/datasources/remote/igdb/idgb_remote_datasource.dart';
import 'data/datasources/remote/igdb/igdb_remote_datasource_impl.dart';
import 'data/datasources/remote/supabase/supabase_remote_datasource.dart';
import 'data/datasources/remote/supabase/supabase_remote_datasource_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/game_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/game_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/auth/get_current_user.dart';
import 'domain/usecases/auth/reset_password.dart';
import 'domain/usecases/auth/sign_in.dart';
import 'domain/usecases/auth/sign_up.dart';
import 'domain/usecases/auth/sign_out.dart';
import 'domain/usecases/auth/update_password.dart';
import 'domain/usecases/game/get_complete_game_details.dart';
import 'domain/usecases/game/get_game_companies.dart';
import 'domain/usecases/game/get_game_dlcs.dart';
import 'domain/usecases/game/get_game_expansions.dart';
import 'domain/usecases/game/get_similar_games.dart';
import 'domain/usecases/game/get_user_top_three.dart';
import 'domain/usecases/game/search_games.dart';
import 'domain/usecases/game/get_game_details.dart';
import 'domain/usecases/game/get_popular_games.dart';
import 'domain/usecases/game/get_upcoming_games.dart';
import 'domain/usecases/game/get_user_wishlist.dart';
import 'domain/usecases/game/get_user_recommendations.dart';
import 'domain/usecases/game/rate_game.dart';
import 'domain/usecases/game/toggle_wishlist.dart';
import 'domain/usecases/user/follow_user.dart';
import 'domain/usecases/user/get_user_followers.dart';
import 'domain/usecases/user/get_user_following.dart';
import 'domain/usecases/user/get_user_profile.dart';
import 'domain/usecases/user/get_user_top_three.dart';
import 'domain/usecases/user/search_users.dart';
import 'domain/usecases/user/update_top_three_games.dart';
import 'domain/usecases/user/update_user_profile.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/game/game_bloc.dart';
import 'core/network/network_info.dart';
import 'core/network/api_client.dart';
import 'domain/usecases/game/toggle_recommend.dart';
import 'domain/usecases/user/add_to_top_three.dart';

final sl = GetIt.instance;

Future<void> init() async {
  print('🔧 DI: Starting dependency injection setup...');

  // External dependencies
  print('📦 DI: Registering external dependencies...');
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());

  // Core
  print('🔨 DI: Registering core dependencies...');
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Data sources
  print('📡 DI: Registering data sources...');
  sl.registerLazySingleton<IGDBRemoteDataSource>(
        () => IGDBRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<SupabaseRemoteDataSource>(
        () => SupabaseRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<LocalDataSource>(
        () => LocalDataSourceImpl(sharedPreferences: sl()),
  );


  // Repositories
  print('🏛️ DI: Registering repositories...');
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<GameRepository>(
        () => GameRepositoryImpl(
      igdbDataSource: sl(),
      supabaseDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases - Auth
  print('🔐 DI: Registering auth use cases...');
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => UpdatePassword(sl()));

  // Use cases - Game
  print('🎮 DI: Registering game use cases...');
  sl.registerLazySingleton(() => SearchGames(sl()));
  sl.registerLazySingleton(() => GetGameDetails(sl()));
  sl.registerLazySingleton(() => GetPopularGames(sl()));
  sl.registerLazySingleton(() => GetUpcomingGames(sl()));
  sl.registerLazySingleton(() => GetUserWishlist(sl()));
  sl.registerLazySingleton(() => GetUserRecommendations(sl()));
  sl.registerLazySingleton(() => RateGame(sl()));
  sl.registerLazySingleton(() => ToggleWishlist(sl()));
  sl.registerLazySingleton(() => ToggleRecommend(sl()));
  sl.registerLazySingleton(() => GetUserRated(sl()));
  sl.registerLazySingleton(() => GetUserTopThree(sl()));
  sl.registerLazySingleton(() => GetCompleteGameDetails(sl()));
  sl.registerLazySingleton(() => GetGameCompanies(sl()));
  sl.registerLazySingleton(() => GetSimilarGames(sl()));
  sl.registerLazySingleton(() => GetGameDLCs(sl()));
  sl.registerLazySingleton(() => GetGameExpansions(sl()));

  // Use cases - User
  print('👤 DI: Registering user use cases...');
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => FollowUser(sl()));
  sl.registerLazySingleton(() => UpdateTopThreeGames(sl()));
  sl.registerLazySingleton(() => SearchUsers(sl()));
  sl.registerLazySingleton(() => GetUserFollowers(sl()));
  sl.registerLazySingleton(() => GetUserFollowing(sl()));
  sl.registerLazySingleton(() => AddToTopThree(sl()));
  sl.registerLazySingleton(() => GetUserTopThreeGames(sl()));

  // BLoCs
  print('🧠 DI: Registering BLoCs...');
  sl.registerFactory(
        () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );

  sl.registerFactory(
        () => GameBloc(
          searchGames: sl(),
          getGameDetails: sl(),
          getCompleteGameDetails: sl(), // NEW
          getSimilarGames: sl(), // NEW
          getGameDLCs: sl(), // NEW
          getGameExpansions: sl(), // NEW
          rateGame: sl(),
          toggleWishlist: sl(),
          toggleRecommend: sl(),
          addToTopThree: sl(),
          getPopularGames: sl(),
          getUpcomingGames: sl(),
          getUserWishlist: sl(),
          getUserRecommendations: sl(),
          getUserTopThreeGames: sl(), getUserRated: sl(), getUserTopThree: sl(),
        ),
  );
  print('✅ DI: Dependency injection setup complete!');
}