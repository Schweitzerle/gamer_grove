// lib/presentation/blocs/user_search/user_search_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user/user.dart';
import '../../../domain/usecases/user/search_users.dart';
import '../../../domain/usecases/user/get_user_followers.dart';
import '../../../domain/usecases/user/get_user_following.dart';
import 'user_search_event.dart';
import 'user_search_state.dart';

/// BLoC for handling user search with pagination
class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final SearchUsers searchUsers;
  final GetFollowersUseCase? getFollowers;
  final GetFollowingUseCase? getFollowing;
  final String? currentUserId;

  static const int _pageSize = 20;

  UserSearchBloc({
    required this.searchUsers,
    this.getFollowers,
    this.getFollowing,
    this.currentUserId,
  }) : super(UserSearchState.initial()) {
    on<SearchUsersRequested>(_onSearchUsersRequested);
    on<LoadMoreUsersRequested>(_onLoadMoreUsersRequested);
    on<RefreshSearchRequested>(_onRefreshSearchRequested);
    on<ClearSearchRequested>(_onClearSearchRequested);
    on<RetrySearchRequested>(_onRetrySearchRequested);
    on<LoadFollowersRequested>(_onLoadFollowersRequested);
    on<LoadFollowingRequested>(_onLoadFollowingRequested);
  }

  /// Handle initial search request
  Future<void> _onSearchUsersRequested(
    SearchUsersRequested event,
    Emitter<UserSearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(state.clear());
      return;
    }

    if (event.query.trim().length < 2) {
      emit(state.error('Search query must be at least 2 characters'));
      return;
    }

    emit(state.loading());

    final result = await searchUsers(
      SearchUsersParams(
        query: event.query.trim(),
        currentUserId: currentUserId,
        limit: _pageSize,
        offset: 0,
      ),
    );

    result.fold(
      (failure) => emit(state.error(failure.message)),
      (users) => emit(
        state.success(
          users: users,
          hasReachedMax: users.length < _pageSize,
          query: event.query.trim(),
          page: 0,
        ),
      ),
    );
  }

  /// Handle loading more users (pagination)
  Future<void> _onLoadMoreUsersRequested(
    LoadMoreUsersRequested event,
    Emitter<UserSearchState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.currentQuery.isEmpty) {
      return;
    }

    emit(state.loadingMore());

    final nextPage = state.currentPage + 1;
    final result = await searchUsers(
      SearchUsersParams(
        query: state.currentQuery,
        currentUserId: currentUserId,
        limit: _pageSize,
        offset: nextPage * _pageSize,
      ),
    );

    result.fold(
      (failure) => emit(state.error(failure.message)),
      (newUsers) {
        final allUsers = List<User>.from(state.users)..addAll(newUsers);
        emit(
          state.success(
            users: allUsers,
            hasReachedMax: newUsers.length < _pageSize,
            query: state.currentQuery,
            page: nextPage,
          ),
        );
      },
    );
  }

  /// Handle refresh request
  Future<void> _onRefreshSearchRequested(
    RefreshSearchRequested event,
    Emitter<UserSearchState> emit,
  ) async {
    if (state.currentQuery.isEmpty) {
      return;
    }

    final result = await searchUsers(
      SearchUsersParams(
        query: state.currentQuery,
        currentUserId: currentUserId,
        limit: _pageSize,
        offset: 0,
      ),
    );

    result.fold(
      (failure) => emit(state.error(failure.message)),
      (users) => emit(
        state.success(
          users: users,
          hasReachedMax: users.length < _pageSize,
          query: state.currentQuery,
          page: 0,
        ),
      ),
    );
  }

  /// Handle clear search request
  Future<void> _onClearSearchRequested(
    ClearSearchRequested event,
    Emitter<UserSearchState> emit,
  ) async {
    emit(state.clear());
  }

  /// Handle retry request
  Future<void> _onRetrySearchRequested(
    RetrySearchRequested event,
    Emitter<UserSearchState> emit,
  ) async {
    if (state.currentQuery.isEmpty) {
      return;
    }

    add(SearchUsersRequested(state.currentQuery));
  }

  /// Handle load followers request
  Future<void> _onLoadFollowersRequested(
    LoadFollowersRequested event,
    Emitter<UserSearchState> emit,
  ) async {
    if (getFollowers == null) {
      emit(state.error('Followers feature not available'));
      return;
    }

    emit(state.loading());

    final result = await getFollowers!(
      GetFollowersParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(state.error(failure.message)),
      (users) => emit(
        state.success(
          users: users,
          hasReachedMax: true,
          query: '',
          page: 0,
        ),
      ),
    );
  }

  /// Handle load following request
  Future<void> _onLoadFollowingRequested(
    LoadFollowingRequested event,
    Emitter<UserSearchState> emit,
  ) async {
    if (getFollowing == null) {
      emit(state.error('Following feature not available'));
      return;
    }

    emit(state.loading());

    final result = await getFollowing!(
      GetFollowingParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(state.error(failure.message)),
      (users) => emit(
        state.success(
          users: users,
          hasReachedMax: true,
          query: '',
          page: 0,
        ),
      ),
    );
  }
}
