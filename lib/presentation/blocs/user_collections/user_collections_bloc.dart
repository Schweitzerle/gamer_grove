import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/usecases/user_collection/add_game_to_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/create_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/delete_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_user_collections_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/remove_game_from_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/update_collection_use_case.dart';

part 'user_collections_event.dart';
part 'user_collections_state.dart';

/// Manages the signed-in user's custom collections.
///
/// The list is the source of truth for the profile "My Collections" section.
/// Mutations (create / rename / delete / add / remove game) keep the loaded
/// list visible and re-fetch it on success so aggregate game counts stay
/// correct; failures surface via [UserCollectionsLoaded.actionError] without
/// dropping the list.
class UserCollectionsBloc
    extends Bloc<UserCollectionsEvent, UserCollectionsState> {
  UserCollectionsBloc({
    required GetUserCollectionsUseCase getUserCollections,
    required CreateCollectionUseCase createCollection,
    required UpdateCollectionUseCase updateCollection,
    required DeleteCollectionUseCase deleteCollection,
    required AddGameToCollectionUseCase addGameToCollection,
    required RemoveGameFromCollectionUseCase removeGameFromCollection,
  })  : _getUserCollections = getUserCollections,
        _createCollection = createCollection,
        _updateCollection = updateCollection,
        _deleteCollection = deleteCollection,
        _addGameToCollection = addGameToCollection,
        _removeGameFromCollection = removeGameFromCollection,
        super(const UserCollectionsInitial()) {
    on<LoadCollections>(_onLoad);
    on<CreateCollection>(_onCreate);
    on<UpdateCollection>(_onUpdate);
    on<DeleteCollection>(_onDelete);
    on<AddGameToCollection>(_onAddGame);
    on<RemoveGameFromCollection>(_onRemoveGame);
  }

  final GetUserCollectionsUseCase _getUserCollections;
  final CreateCollectionUseCase _createCollection;
  final UpdateCollectionUseCase _updateCollection;
  final DeleteCollectionUseCase _deleteCollection;
  final AddGameToCollectionUseCase _addGameToCollection;
  final RemoveGameFromCollectionUseCase _removeGameFromCollection;

  /// The user id of the currently loaded list, if any.
  String? get _userId {
    final s = state;
    return s is UserCollectionsLoaded ? s.userId : null;
  }

  Future<void> _onLoad(
    LoadCollections event,
    Emitter<UserCollectionsState> emit,
  ) async {
    // Only show the full-screen loader when we have nothing to show.
    if (state is! UserCollectionsLoaded) {
      emit(const UserCollectionsLoading());
    }
    final result = await _getUserCollections(
      GetUserCollectionsParams(userId: event.userId),
    );
    result.fold(
      (failure) {
        if (state is UserCollectionsLoaded) return;
        emit(UserCollectionsError(_message(failure)));
      },
      (collections) => emit(
        UserCollectionsLoaded(
          userId: event.userId,
          collections: collections,
        ),
      ),
    );
  }

  Future<void> _onCreate(
    CreateCollection event,
    Emitter<UserCollectionsState> emit,
  ) async {
    _beginMutation(emit);
    final result = await _createCollection(
      CreateCollectionParams(
        userId: event.userId,
        name: event.name,
        description: event.description,
      ),
    );
    await _finishMutation(result, event.userId, emit);
  }

  Future<void> _onUpdate(
    UpdateCollection event,
    Emitter<UserCollectionsState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    _beginMutation(emit);
    final result = await _updateCollection(
      UpdateCollectionParams(
        collectionId: event.collectionId,
        name: event.name,
        description: event.description,
        isPublic: event.isPublic,
      ),
    );
    await _finishMutation(result, userId, emit);
  }

  Future<void> _onDelete(
    DeleteCollection event,
    Emitter<UserCollectionsState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    _beginMutation(emit);
    final result = await _deleteCollection(
      DeleteCollectionParams(collectionId: event.collectionId),
    );
    await _finishMutation(result, userId, emit);
  }

  Future<void> _onAddGame(
    AddGameToCollection event,
    Emitter<UserCollectionsState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    _beginMutation(emit);
    final result = await _addGameToCollection(
      AddGameToCollectionParams(
        collectionId: event.collectionId,
        gameId: event.gameId,
      ),
    );
    await _finishMutation(result, userId, emit);
  }

  Future<void> _onRemoveGame(
    RemoveGameFromCollection event,
    Emitter<UserCollectionsState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    _beginMutation(emit);
    final result = await _removeGameFromCollection(
      RemoveGameFromCollectionParams(
        collectionId: event.collectionId,
        gameId: event.gameId,
      ),
    );
    await _finishMutation(result, userId, emit);
  }

  void _beginMutation(Emitter<UserCollectionsState> emit) {
    final s = state;
    if (s is UserCollectionsLoaded) {
      emit(s.copyWith(isMutating: true));
    }
  }

  /// Reloads the list on success, or surfaces the error on the loaded state.
  Future<void> _finishMutation(
    Either<Failure, Object?> result,
    String userId,
    Emitter<UserCollectionsState> emit,
  ) async {
    await result.fold(
      (failure) async {
        final s = state;
        if (s is UserCollectionsLoaded) {
          emit(s.copyWith(isMutating: false, actionError: _message(failure)));
        } else {
          emit(UserCollectionsError(_message(failure)));
        }
      },
      (_) async {
        final reload = await _getUserCollections(
          GetUserCollectionsParams(userId: userId),
        );
        reload.fold(
          (failure) {
            final s = state;
            if (s is UserCollectionsLoaded) {
              emit(s.copyWith(isMutating: false));
            } else {
              emit(UserCollectionsError(_message(failure)));
            }
          },
          (collections) => emit(
            UserCollectionsLoaded(userId: userId, collections: collections),
          ),
        );
      },
    );
  }

  String _message(Failure failure) => failure.message;
}
