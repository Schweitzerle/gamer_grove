// ==================================================
// Platform DETAIL PAGE (WRAPPER WITH BLOC)
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_bloc.dart';
import 'package:gamer_grove/presentation/pages/platform/platform_details_screen.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/platform/platform_event.dart';
import '../../blocs/platform/platform_state.dart';
import '../../widgets/live_loading_progress.dart';

class PlatformDetailPage extends StatelessWidget {
  final int platformId;
  final Platform? platform; // Optional pre-loaded platform

  const PlatformDetailPage({
    super.key,
    required this.platformId,
    this.platform,
  });

  @override
  Widget build(BuildContext context) {
    print('🎭 PlatformDetailPage: Building for platform ID: $platformId');

    return BlocProvider<PlatformBloc>(
      create: (context) {
        print('🎭 PlatformDetailPage: Creating PlatformBloc');
        final bloc = sl<PlatformBloc>();
        // 🆕 Hole userId von AuthBloc
        final authState = context.read<AuthBloc>().state;
        final userId = authState is Authenticated ? authState.user.id : null;
        print('🎭 PlatformDetailPage: Adding GetPlatformDetailsEvent');
        bloc.add(GetPlatformDetailsEvent(
            platformId: platformId,
            includeGames: true, // 🆕 Explicitly set to true
            userId: userId
        ));
        return bloc;
      },
      child: BlocBuilder<PlatformBloc, PlatformState>(
        builder: (context, state) {
          print('🎭 PlatformDetailPage: State changed to ${state.runtimeType}');

          if (state is PlatformLoading) {
            print('🔄 PlatformDetailPage: Loading state');
            return _buildLiveLoadingState(context);
          } else if (state is PlatformDetailsLoaded) {
            print('✅ PlatformDetailPage: Loaded state - ${state.platform.name} with ${state.games.length} games');
            return PlatformDetailScreen(
              platform: state.platform,
              games: state.games,
            );
          } else if (state is PlatformError) {
            print('❌ PlatformDetailPage: Error state - ${state.message}');
            return _buildErrorState(context, state.message);
          }

          print('🔄 PlatformDetailPage: Default loading state');
          return _buildLiveLoadingState(context);
        },
      ),
    );
  }


  Widget _buildLiveLoadingState(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LiveLoadingProgress(
            title: 'Loading Platform Details',
            steps: PlatformLoadingSteps.platformDetails(context),
            stepDuration: const Duration(milliseconds: 900),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Platform Details',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon with Theme Color
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),

              const SizedBox(height: 24),

              // Error Title
              Text(
                'Failed to Load Platform',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Error Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Retry Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<PlatformBloc>().add(
                      GetPlatformDetailsEvent(platformId: platformId),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Loading'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Go Back Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
