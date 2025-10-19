// ==================================================
// CHARACTER BLOC IMPLEMENTATION
// ==================================================

// lib/presentation/blocs/character/character_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/game_enrichment_service.dart';
import '../../../domain/usecases/characters/get_character_with_games.dart';
import 'character_event.dart';
import 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final GetCharacterWithGames getCharacterWithGames;
  final GameEnrichmentService enrichmentService;

  CharacterBloc({
    required this.getCharacterWithGames,
    required this.enrichmentService,
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
        // Enrich games with user data using the new service
        if (event.userId != null && characterWithGames.games.isNotEmpty) {
          try {
            final enrichedGames = await enrichmentService.enrichGames(
              characterWithGames.games,
              event.userId!,
            );

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
