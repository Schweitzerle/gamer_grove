// ==================================================
// CHARACTER DETAIL PAGE (WRAPPER WITH BLOC)
// ==================================================

// lib/presentation/pages/character_detail/character_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../domain/entities/character/character.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/character/character_bloc.dart';
import '../../blocs/character/character_event.dart';
import '../../blocs/character/character_state.dart';
import '../../widgets/character_laoding_steps.dart';
import '../../widgets/live_loading_progress.dart' hide CharacterLoadingSteps;
import 'character_detail_screen.dart';

class CharacterDetailPage extends StatelessWidget {
  final int characterId;
  final Character? character; // Optional pre-loaded character

  const CharacterDetailPage({
    super.key,
    required this.characterId,
    this.character,
  });

  @override
  Widget build(BuildContext context) {

    return BlocProvider<CharacterBloc>(
      create: (context) {
        final bloc = sl<CharacterBloc>();
        // 🆕 Hole userId von AuthBloc
        final authState = context.read<AuthBloc>().state;
        final userId =
            authState is AuthAuthenticated ? authState.user.id : null;
        bloc.add(GetCharacterDetailsEvent(
            characterId: characterId,
            includeGames: true, // 🆕 Explicitly set to true
            userId: userId));
        return bloc;
      },
      child: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {

          if (state is CharacterLoading) {
            return _buildLiveLoadingState(context);
          } else if (state is CharacterDetailsLoaded) {
            return CharacterDetailScreen(
              character: state.character,
              games: state.games,
            );
          } else if (state is CharacterError) {
            return _buildErrorState(context, state.message);
          }

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
            title: 'Loading Character Details',
            steps: CharacterLoadingSteps.characterDetails(context),
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
      context.read<CharacterBloc>().add(
            GetCharacterDetailsEvent(
              characterId: characterId,
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
          'Character Details',
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
