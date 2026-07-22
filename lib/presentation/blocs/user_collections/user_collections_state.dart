part of 'user_collections_bloc.dart';

/// Base state for the custom-collections bloc.
sealed class UserCollectionsState extends Equatable {
  const UserCollectionsState();

  @override
  List<Object?> get props => [];
}

/// Nothing loaded yet.
class UserCollectionsInitial extends UserCollectionsState {
  const UserCollectionsInitial();
}

/// First load in progress (no data to show yet).
class UserCollectionsLoading extends UserCollectionsState {
  const UserCollectionsLoading();
}

/// Initial load failed (no data to show).
class UserCollectionsError extends UserCollectionsState {
  const UserCollectionsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Collections are available.
///
/// [isMutating] flags an in-flight create/update/delete/membership change so
/// the UI can show progress while keeping the list visible. [actionError]
/// carries a one-shot failure message for the last mutation (the list itself
/// stays intact); consumers should surface it (e.g. a toast) and it is cleared
/// on the next event.
class UserCollectionsLoaded extends UserCollectionsState {
  const UserCollectionsLoaded({
    required this.userId,
    required this.collections,
    this.isMutating = false,
    this.actionError,
  });

  final String userId;
  final List<UserCollection> collections;
  final bool isMutating;
  final String? actionError;

  int get count => collections.length;

  UserCollectionsLoaded copyWith({
    String? userId,
    List<UserCollection>? collections,
    bool? isMutating,
    String? actionError,
  }) {
    return UserCollectionsLoaded(
      userId: userId ?? this.userId,
      collections: collections ?? this.collections,
      isMutating: isMutating ?? this.isMutating,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [userId, collections, isMutating, actionError];
}
