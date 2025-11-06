// presentation/pages/splash/splash_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';
import 'package:gamer_grove/presentation/pages/profile/profile_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSplashSequence();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  void _startSplashSequence() async {
    // Start animations
    _animationController.forward();

    // Wait for minimum splash duration
    await Future<void>.delayed(const Duration(seconds: 2));

    // Check auth status with timeout
    if (mounted) {
      print('🚀 SplashPage: Checking auth status...');
      context.read<AuthBloc>().add(const CheckAuthStatusEvent());

      // Add a safety timeout
      Future<void>.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          final currentState = context.read<AuthBloc>().state;
          print(
              '⏰ SplashPage: Timeout reached, current state: ${currentState.runtimeType}');
          if (currentState is AuthLoading) {
            print(
                '🔧 SplashPage: Still loading after timeout, forcing navigation to login');
            _navigateToLogin();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔥 SplashPage: Auth state changed to ${state.runtimeType}');

        if (state is AuthAuthenticated) {
          print('✅ SplashPage: User authenticated, navigating to home');
          _navigateToHome();
        } else if (state is AuthUnauthenticated) {
          print('❌ SplashPage: User not authenticated, navigating to login');
          _navigateToLogin();
        } else if (state is AuthError) {
          print('💥 SplashPage: Auth error: ${state.message}');
          _navigateToLogin(); // Navigate to login on error
        }
        // Don't navigate on AuthLoading - let it complete
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Title Animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            // App Icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.gamepad_rounded,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            // App Name
                            Text(
                              AppConstants.appName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),

                            // App Tagline
                            Text(
                              AppConstants.appDescription,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppConstants.paddingXLarge * 2),

                // Loading Indicator
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    String loadingText = 'Loading...';

                    if (state is AuthLoading) {
                      loadingText = 'Checking authentication...';
                    } else if (state is AuthError) {
                      loadingText = 'Error: ${state.message}';
                    }

                    return Column(
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          loadingText,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: AppConstants.paddingSmall),
                          Text(
                            'State: ${state.runtimeType}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: AppConstants.paddingLarge),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: const Text('Go to Profile (Dev)'),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Bottom branding
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Text(
            'Version ${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: AppConstants.mediumAnimation,
        ),
      );
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: AppConstants.mediumAnimation,
        ),
      );
    }
  }
}
