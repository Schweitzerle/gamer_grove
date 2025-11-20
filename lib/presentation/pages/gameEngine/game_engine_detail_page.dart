// ==================================================
// Platform DETAIL PAGE (WRAPPER WITH BLOC)
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/widgets/error_widget.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import 'package:gamer_grove/presentation/blocs/game_engine/game_engine_bloc.dart';
import 'package:gamer_grove/presentation/blocs/game_engine/game_engine_event.dart';
import 'package:gamer_grove/presentation/blocs/game_engine/game_engine_state.dart';
import 'package:gamer_grove/presentation/pages/gameEngine/game_engine_details_screen.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/live_loading_progress.dart';

class GameEngineDetailPage extends StatelessWidget {
  final int gameEngineId;
  final GameEngine? gameEngine; // Optional pre-loaded gameEngine

  const GameEngineDetailPage({
    super.key,
    required this.gameEngineId,
    this.gameEngine,
  });

  @override
  Widget build(BuildContext context) {
    print('🎭 GameEngineDetailPage: Building for gameEngine ID: $gameEngineId');

    return BlocProvider<GameEngineBloc>(
      create: (context) {
        print('🎭 GameEngineDetailPage: Creating GameEngineBloc');
        final bloc = sl<GameEngineBloc>();
        // 🆕 Hole userId von AuthBloc
        final authState = context.read<AuthBloc>().state;
        final userId =
            authState is AuthAuthenticated ? authState.user.id : null;
        print('🎭 GameEngineDetailPage: Adding GetGameEngineDetailsEvent');
        bloc.add(GetGameEngineDetailsEvent(
            gameEngineId: gameEngineId,
            includeGames: true, // 🆕 Explicitly set to true
            userId: userId));
        return bloc;
      },
      child: BlocBuilder<GameEngineBloc, GameEngineState>(
        builder: (context, state) {
          print(
              '🎭 GameEngineDetailPage: State changed to ${state.runtimeType}');

          if (state is GameEngineLoading) {
            print('🔄 GameEngineDetailPage: Loading state');
            return _buildLiveLoadingState(context);
          } else if (state is GameEngineDetailsLoaded) {
            print(
                '✅ GameEngineDetailPage: Loaded state - ${state.gameEngine.name} with ${state.games.length} games');
            return GameEngineDetailScreen(
              gameEngine: state.gameEngine,
              games: state.games,
            );
          } else if (state is GameEngineError) {
            print('❌ GameEngineDetailPage: Error state - ${state.message}');
            return _buildErrorState(context, state.message);
          }

          print('🔄 GameEngineDetailPage: Default loading state');
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
            title: 'Loading Game Engine Details',
            steps: GameEngineLoadingSteps.gameEngineDetails(context),
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
      context.read<GameEngineBloc>().add(
            GetGameEngineDetailsEvent(
              gameEngineId: gameEngineId,
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
          'Game Engine Details',
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
