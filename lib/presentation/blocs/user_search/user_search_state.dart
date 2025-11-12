// lib/presentation/blocs/user_search/user_search_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user/user.dart';

/// Represents the state of user search
class UserSearchState extends Equatable {
  final List<User> users;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? errorMessage;
  final String currentQuery;
  final int currentPage;

  const UserSearchState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage,
    this.currentQuery = '',
    this.currentPage = 0,
  });

  /// Initial state
  factory UserSearchState.initial() => const UserSearchState();

  /// Loading state (first page)
  UserSearchState loading() => copyWith(
        isLoading: true,
        errorMessage: null,
      );

  /// Loading more state (pagination)
  UserSearchState loadingMore() => copyWith(
        isLoadingMore: true,
        errorMessage: null,
      );

  /// Success state with users
  UserSearchState success({
    required List<User> users,
    required bool hasReachedMax,
    required String query,
    required int page,
  }) =>
      copyWith(
        users: users,
        isLoading: false,
        isLoadingMore: false,
        hasReachedMax: hasReachedMax,
        errorMessage: null,
        currentQuery: query,
        currentPage: page,
      );

  /// Error state
  UserSearchState error(String message) => copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: message,
      );

  /// Clear/Empty state
  UserSearchState clear() => const UserSearchState();

  bool get isEmpty => users.isEmpty && !isLoading;
  bool get hasError => errorMessage != null;
  bool get hasUsers => users.isNotEmpty;
  bool get isSearching => currentQuery.isNotEmpty;

  UserSearchState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
    String? currentQuery,
    int? currentPage,
  }) {
    return UserSearchState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
      currentQuery: currentQuery ?? this.currentQuery,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        users,
        isLoading,
        isLoadingMore,
        hasReachedMax,
        errorMessage,
        currentQuery,
        currentPage,
      ];
}
