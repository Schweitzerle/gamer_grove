// lib/presentation/widgets/header_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';

class HeaderSection extends StatelessWidget {

  const HeaderSection({
    super.key,
    this.onSearchPressed,
    this.onWishlistPressed,
    this.onSupabaseTestPressed,
    this.onIGDBTestPressed,
  });
  final VoidCallback? onSearchPressed;
  final VoidCallback? onWishlistPressed;
  final VoidCallback? onSupabaseTestPressed;
  final VoidCallback? onIGDBTestPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          /*  const SizedBox(height: AppConstants.paddingLarge),
          _buildQuickActions(context),
          if (kDebugMode) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            _buildDebugActions(context),
          ], */
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return _AuthenticatedWelcome(user: authState.user);
        } else {
          return const _GuestWelcome();
        }
      },
    );
  }
  // Default navigation methods
}

// Private sub-widgets for better organization
class _AuthenticatedWelcome extends StatelessWidget { // Replace with your User model

  const _AuthenticatedWelcome({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${user.username}!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          'Discover your next favorite game',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _GuestWelcome extends StatelessWidget {
  const _GuestWelcome();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover Amazing Games',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          'Find, rate, and track your gaming journey',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
