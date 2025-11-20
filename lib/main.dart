// lib/main.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gamer_grove/injection_container.dart' as di;
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart'
    as app_auth;
import 'package:gamer_grove/presentation/blocs/theme/theme_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_state.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/pages/splash/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // System UI
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  // Setup Dependency Injection (includes Supabase initialization)
  await di.initDependencies();

  runApp(const GamerGroveApp());
}

class GamerGroveApp extends StatelessWidget {
  const GamerGroveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Bloc - manages authentication state
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        // UserGameData Bloc - global state for user-game relations
        // Uses LazySingleton to persist across the app
        BlocProvider.value(
          value: sl<UserGameDataBloc>(),
        ),
        // Theme Bloc - manages app theme
        BlocProvider(
          create: (_) => ThemeBloc()..add(const ThemeLoadStarted()),
        ),
      ],
      child: _UserGameDataListener(
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Gamer Grove',
              debugShowCheckedModeBanner: false,
              theme: FlexThemeData.light(
                scheme: state.flexScheme,
                surfaceMode: FlexSurfaceMode.level,
                blendLevel: 30,
              ),
              darkTheme: FlexThemeData.dark(
                scheme: state.flexScheme,
                surfaceMode: FlexSurfaceMode.level,
                blendLevel: 30,
              ),
              themeMode: state.themeMode,
              home: const SplashPage(),
            );
          },
        ),
      ),
    );
  }
}

/// Listener widget that loads user game data when user logs in
/// and clears it when user logs out
class _UserGameDataListener extends StatelessWidget {

  const _UserGameDataListener({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, app_auth.AuthState>(
      listener: (context, authState) {
        final userGameDataBloc = context.read<UserGameDataBloc>();

        if (authState is app_auth.AuthAuthenticated) {
          // User logged in - load their game data
          userGameDataBloc.add(LoadUserGameDataEvent(authState.user.id));
        } else if (authState is app_auth.AuthUnauthenticated) {
          // User logged out - clear game data
          userGameDataBloc.add(const ClearUserGameDataEvent());
        }
      },
      child: child,
    );
  }
}

// Global Supabase client access
final SupabaseClient supabase = Supabase.instance.client;
