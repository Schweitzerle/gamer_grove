// ==================================================
// CHARACTER BLOC IMPLEMENTATION
// ==================================================

// lib/presentation/blocs/character/character_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/game_enrichment_utils.dart';
import '../../../domain/usecases/characters/get_character_with_games.dart';
import 'character_event.dart';
import 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final GetCharacterWithGames getCharacterWithGames;

  CharacterBloc({
    required this.getCharacterWithGames,
  }) : super(CharacterInitial()) {
    on<GetCharacterDetailsEvent>(_onGetCharacterDetails);
    on<ClearCharacterEvent>(_onClearCharacter);
  }

  Future<void> _onGetCharacterDetails(
      GetCharacterDetailsEvent event,
      Emitter<CharacterState> emit,
      ) async {
    emit(CharacterLoading());

    final result = await getCharacterWithGames(
      GetCharacterWithGamesParams(
        characterId: event.characterId,
        includeGames: event.includeGames,
      ),
    );

    await result.fold(
          (failure) async {
        emit(CharacterError(message: failure.message));
      },
          (characterWithGames) async {
        // 🔧 NEUE ENRICHMENT LOGIC mit Utils
        if (event.userId != null && characterWithGames.games.isNotEmpty) {
          try {
            print('🎭 CharacterBloc: Enriching character games with GameEnrichmentUtils...');

            // 🆕 Verwende die Utils statt eigene Implementierung
            final enrichedGames = await GameEnrichmentUtils.enrichCharacterGames(
              characterWithGames.games,
              event.userId!,
            );

            // 🆕 Debug Stats
            GameEnrichmentUtils.printEnrichmentStats(enrichedGames, context: 'Character');

            emit(CharacterDetailsLoaded(
              character: characterWithGames.character,
              games: enrichedGames,
            ));
          } catch (e) {
            print('❌ CharacterBloc: Failed to enrich games: $e');
            emit(CharacterDetailsLoaded(
              character: characterWithGames.character,
              games: characterWithGames.games,
            ));
          }
        } else {
          emit(CharacterDetailsLoaded(
            character: characterWithGames.character,
            games: characterWithGames.games,
          ));
        }
      },
    );
  }

  Future<void> _onClearCharacter(
      ClearCharacterEvent event,
      Emitter<CharacterState> emit,
      ) async {
    emit(CharacterInitial());
  }
}


