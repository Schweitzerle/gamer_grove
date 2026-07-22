part of 'user_collections_bloc.dart';

/// Base event for the custom-collections bloc.
abstract class UserCollectionsEvent extends Equatable {
  const UserCollectionsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or reloads) the owner's collections.
class LoadCollections extends UserCollectionsEvent {
  const LoadCollections(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Creates a new collection for the current owner.
class CreateCollection extends UserCollectionsEvent {
  const CreateCollection({
    required this.userId,
    required this.name,
    this.description,
  });

  final String userId;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [userId, name, description];
}

/// Renames / edits an existing collection.
class UpdateCollection extends UserCollectionsEvent {
  const UpdateCollection({
    required this.collectionId,
    this.name,
    this.description,
    this.isPublic,
  });

  final String collectionId;
  final String? name;
  final String? description;
  final bool? isPublic;

  @override
  List<Object?> get props => [collectionId, name, description, isPublic];
}

/// Deletes a collection.
class DeleteCollection extends UserCollectionsEvent {
  const DeleteCollection(this.collectionId);

  final String collectionId;

  @override
  List<Object?> get props => [collectionId];
}

/// Adds a game to a collection (then refreshes counts).
class AddGameToCollection extends UserCollectionsEvent {
  const AddGameToCollection({
    required this.collectionId,
    required this.gameId,
  });

  final String collectionId;
  final int gameId;

  @override
  List<Object?> get props => [collectionId, gameId];
}

/// Removes a game from a collection (then refreshes counts).
class RemoveGameFromCollection extends UserCollectionsEvent {
  const RemoveGameFromCollection({
    required this.collectionId,
    required this.gameId,
  });

  final String collectionId;
  final int gameId;

  @override
  List<Object?> get props => [collectionId, gameId];
}
