// lib/presentation/blocs/user_search/user_search_event.dart

import 'package:equatable/equatable.dart';

/// Base class for all user search events
abstract class UserSearchEvent extends Equatable {
  const UserSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to search for users with a query
class SearchUsersRequested extends UserSearchEvent {

  const SearchUsersRequested(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to load more users (pagination)
class LoadMoreUsersRequested extends UserSearchEvent {
  const LoadMoreUsersRequested();
}

/// Event to refresh the search results
class RefreshSearchRequested extends UserSearchEvent {
  const RefreshSearchRequested();
}

/// Event to clear search results
class ClearSearchRequested extends UserSearchEvent {
  const ClearSearchRequested();
}

/// Event to retry after error
class RetrySearchRequested extends UserSearchEvent {
  const RetrySearchRequested();
}

/// Event to load followers for a user
class LoadFollowersRequested extends UserSearchEvent {

  const LoadFollowersRequested(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to load following for a user
class LoadFollowingRequested extends UserSearchEvent {

  const LoadFollowingRequested(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}
