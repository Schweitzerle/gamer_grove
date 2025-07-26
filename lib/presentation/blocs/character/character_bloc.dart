// ==================================================
// CHARACTER BLOC IMPLEMENTATION
// ==================================================

// lib/presentation/blocs/character/character_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
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

    result.fold(
          (failure) => emit(CharacterError(message: failure.message)),
          (characterWithGames) => emit(CharacterDetailsLoaded(
        character: characterWithGames.character,
        games: characterWithGames.games,
      )),
    );
  }

  Future<void> _onClearCharacter(
      ClearCharacterEvent event,
      Emitter<CharacterState> emit,
      ) async {
    emit(CharacterInitial());
  }
}


