// lib/main.dart
import 'dart:async';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
import 'package:gamer_grove/core/env/env.dart';
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
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  unawaited(
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    ),
  );

  // Setup Dependency Injection (includes Supabase initialization)
  await di.initDependencies();

  // Configure billing (RevenueCat) when a key is present; no-op otherwise.
  await di.initBilling();

  // Runs the app and records the funnel-start event (no-op unless Umami
  // is configured).
  Future<void> startApp() async {
    unawaited(sl<AnalyticsService>().track(AnalyticsEvents.appOpen));
    runApp(const GamerGroveApp());
  }

  // Crash reporting via Sentry — only when a DSN is configured, so local/CI
  // builds without the DSN run unchanged. Sentry must wrap runApp to capture
  // Flutter framework errors.
  if (Env.sentryDsn.isEmpty) {
    await startApp();
  } else {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = Env.sentryDsn
          ..environment = kReleaseMode ? 'production' : 'debug'
          ..tracesSampleRate = kReleaseMode ? 0.2 : 1.0
          // Don't send user IP / PII by default (GDPR-friendly).
          ..sendDefaultPii = false;
      },
      appRunner: startApp,
    );
  }
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
              title: 'GamerGrove',
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
