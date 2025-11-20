// ==================================================
// Platform DETAIL PAGE (WRAPPER WITH BLOC)
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_bloc.dart';
import 'package:gamer_grove/presentation/pages/platform/platform_details_screen.dart';
import '../../../core/widgets/error_widget.dart';
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
        final userId =
            authState is AuthAuthenticated ? authState.user.id : null;
        print('🎭 PlatformDetailPage: Adding GetPlatformDetailsEvent');
        bloc.add(GetPlatformDetailsEvent(
            platformId: platformId,
            includeGames: true, // 🆕 Explicitly set to true
            userId: userId));
        return bloc;
      },
      child: BlocBuilder<PlatformBloc, PlatformState>(
        builder: (context, state) {
          print('🎭 PlatformDetailPage: State changed to ${state.runtimeType}');

          if (state is PlatformLoading) {
            print('🔄 PlatformDetailPage: Loading state');
            return _buildLiveLoadingState(context);
          } else if (state is PlatformDetailsLoaded) {
            print(
                '✅ PlatformDetailPage: Loaded state - ${state.platform.name} with ${state.games.length} games');
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
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
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
    // Check if it's a network error
    final isNetworkError = message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('timeout');

    // Retry callback
    void retry() {
      final authState = context.read<AuthBloc>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : null;
      context.read<PlatformBloc>().add(
            GetPlatformDetailsEvent(
              platformId: platformId,
              includeGames: true,
              userId: userId,
            ),
          );
    }

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
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isNetworkError
          ? NetworkErrorWidget(onRetry: retry)
          : CustomErrorWidget(
              message: message,
              onRetry: retry,
            ),
    );
  }
}
