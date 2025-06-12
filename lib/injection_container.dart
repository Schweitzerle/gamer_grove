// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Import all your classes here
import 'data/datasources/local/cache_datasource.dart';
import 'data/datasources/remote/idgb_remote_datasource.dart';
import 'data/datasources/remote/supabase_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/game_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/game_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/auth/sign_in.dart';
import 'domain/usecases/auth/sign_up.dart';
import 'domain/usecases/auth/sign_out.dart';
import 'domain/usecases/game/search_games.dart';
import 'domain/usecases/game/get_game_details.dart';
import 'domain/usecases/game/rate_game.dart';
import 'domain/usecases/game/toggle_wishlist.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/game/game_bloc.dart';
import 'core/network/network_info.dart';
import 'core/network/api_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(
        () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
    ),
  );

  sl.registerFactory(
        () => GameBloc(
      searchGames: sl(),
      getGameDetails: sl(),
      rateGame: sl(),
      toggleWishlist: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => SearchGames(sl()));
  sl.registerLazySingleton(() => GetGameDetails(sl()));
  sl.registerLazySingleton(() => RateGame(sl()));
  sl.registerLazySingleton(() => ToggleWishlist(sl()));

  // Repository
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

  // Data sources
  sl.registerLazySingleton<IGDBRemoteDataSource>(
        () => IGDBRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<SupabaseRemoteDataSource>(
        () => SupabaseRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<LocalDataSource>(
        () => LocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
}