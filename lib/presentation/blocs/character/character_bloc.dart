// ==================================================
// CHARACTER BLOC IMPLEMENTATION
// ==================================================

// lib/presentation/blocs/character/character_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import 'package:gamer_grove/domain/entities/search/character_search_filters.dart';
import 'package:gamer_grove/domain/repositories/character_repository.dart';
import 'package:gamer_grove/domain/usecases/characters/get_character_with_games.dart';
import 'package:gamer_grove/presentation/blocs/character/character_event.dart';
import 'package:gamer_grove/presentation/blocs/character/character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {

  CharacterBloc({
    required this.getCharacterWithGames,
    required this.enrichmentService,
    required this.characterRepository,
  }) : super(CharacterInitial()) {
    on<GetCharacterDetailsEvent>(_onGetCharacterDetails);
    on<ClearCharacterEvent>(_onClearCharacter);
    on<GetPopularCharactersEvent>(_onGetPopularCharacters);
    on<SearchCharactersEvent>(_onSearchCharacters);
    on<SearchCharactersWithFiltersEvent>(_onSearchCharactersWithFilters);
    on<LoadMoreCharactersEvent>(_onLoadMoreCharacters);
    on<ClearCharacterSearchEvent>(_onClearCharacterSearch);
  }
  final GetCharacterWithGames getCharacterWithGames;
  final GameEnrichmentService enrichmentService;
  final CharacterRepository characterRepository;

  // Pagination state
  String _currentQuery = '';
  CharacterSearchFilters _currentFilters = const CharacterSearchFilters();
  int _currentOffset = 0;
  static const int _pageSize = 20;

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
            ),);
          } catch (e) {
            emit(CharacterDetailsLoaded(
              character: characterWithGames.character,
              games: characterWithGames.games,
            ),);
          }
        } else {
          emit(CharacterDetailsLoaded(
            character: characterWithGames.character,
            games: characterWithGames.games,
          ),);
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

  Future<void> _onGetPopularCharacters(
    GetPopularCharactersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    emit(CharacterLoading());

    final result = await characterRepository.getPopularCharacters(
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(CharacterError(message: failure.message)),
      (characters) => emit(PopularCharactersLoaded(characters: characters)),
    );
  }

  Future<void> _onSearchCharacters(
    SearchCharactersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(CharacterInitial());
      return;
    }

    emit(const CharacterSearchLoading());

    final result = await characterRepository.searchCharacters(event.query);

    result.fold(
      (failure) => emit(CharacterError(message: failure.message)),
      (characters) => emit(CharacterSearchLoaded(
        characters: characters,
        query: event.query,
      ),),
    );
  }

  Future<void> _onSearchCharactersWithFilters(
    SearchCharactersWithFiltersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    // Reset pagination state
    _currentQuery = event.query;
    _currentFilters = event.filters;
    _currentOffset = 0;

    emit(const CharacterSearchLoading());

    final result = await characterRepository.advancedCharacterSearch(
      filters: event.filters,
      textQuery: event.query.isNotEmpty ? event.query : null,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(CharacterError(message: failure.message)),
      (characters) {
        _currentOffset = characters.length;
        emit(CharacterSearchLoaded(
          characters: characters,
          query: event.query,
          hasReachedMax: characters.length < event.limit,
        ),);
      },
    );
  }

  Future<void> _onLoadMoreCharacters(
    LoadMoreCharactersEvent event,
    Emitter<CharacterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CharacterSearchLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await characterRepository.advancedCharacterSearch(
      filters: _currentFilters,
      textQuery: _currentQuery.isNotEmpty ? _currentQuery : null,
      offset: _currentOffset,
    );

    result.fold(
      (failure) => emit(CharacterError(
        message: failure.message,
        characters: currentState.characters,
      ),),
      (newCharacters) {
        _currentOffset += newCharacters.length;
        emit(currentState.copyWith(
          characters: [...currentState.characters, ...newCharacters],
          hasReachedMax: newCharacters.length < _pageSize,
          isLoadingMore: false,
        ),);
      },
    );
  }

  Future<void> _onClearCharacterSearch(
    ClearCharacterSearchEvent event,
    Emitter<CharacterState> emit,
  ) async {
    _currentQuery = '';
    _currentFilters = const CharacterSearchFilters();
    _currentOffset = 0;
    emit(CharacterInitial());
  }
}
