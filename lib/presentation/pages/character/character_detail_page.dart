// ==================================================
// CHARACTER DETAIL PAGE (WRAPPER WITH BLOC)
// ==================================================

// lib/presentation/pages/character_detail/character_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
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
    print('🎭 CharacterDetailPage: Building for character ID: $characterId');

    return BlocProvider<CharacterBloc>(
      create: (context) {
        print('🎭 CharacterDetailPage: Creating CharacterBloc');
        final bloc = sl<CharacterBloc>();
        // 🆕 Hole userId von AuthBloc
        final authState = context.read<AuthBloc>().state;
        final userId =
            authState is AuthAuthenticated ? authState.user.id : null;
        print('🎭 CharacterDetailPage: Adding GetCharacterDetailsEvent');
        bloc.add(GetCharacterDetailsEvent(
            characterId: characterId,
            includeGames: true, // 🆕 Explicitly set to true
            userId: userId));
        return bloc;
      },
      child: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {
          print(
              '🎭 CharacterDetailPage: State changed to ${state.runtimeType}');

          if (state is CharacterLoading) {
            print('🔄 CharacterDetailPage: Loading state');
            return _buildLiveLoadingState(context);
          } else if (state is CharacterDetailsLoaded) {
            print(
                '✅ CharacterDetailPage: Loaded state - ${state.character.name} with ${state.games.length} games');
            return CharacterDetailScreen(
              character: state.character,
              games: state.games,
            );
          } else if (state is CharacterError) {
            print('❌ CharacterDetailPage: Error state - ${state.message}');
            return _buildErrorState(context, state.message);
          }

          print('🔄 CharacterDetailPage: Default loading state');
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
                'Failed to Load Character',
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
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                    context.read<CharacterBloc>().add(
                          GetCharacterDetailsEvent(characterId: characterId),
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
