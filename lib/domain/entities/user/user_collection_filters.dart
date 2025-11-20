// lib/domain/entities/user/user_collection_filters.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_sort_options.dart';

class UserCollectionFilters extends Equatable {

  const UserCollectionFilters({
    this.genreIds = const [],
    this.platformIds = const [],
    this.minRating,
    this.maxRating,
    this.minUserRating,
    this.maxUserRating,
    this.releaseDateFrom,
    this.releaseDateTo,
    this.addedDateFrom,
    this.addedDateTo,
    this.releaseYears = const [],
    this.sortBy = UserCollectionSortBy.dateAdded,
    this.sortOrder = SortOrder.descending,
  });
  final List<int> genreIds;
  final List<int> platformIds;
  final double? minRating; // Game rating
  final double? maxRating; // Game rating
  final double? minUserRating; // User's own rating
  final double? maxUserRating; // User's own rating
  final DateTime? releaseDateFrom;
  final DateTime? releaseDateTo;
  final DateTime? addedDateFrom;
  final DateTime? addedDateTo;
  final List<int> releaseYears;
  final UserCollectionSortBy sortBy;
  final SortOrder sortOrder;

  // Helper methods
  bool get hasFilters =>
      genreIds.isNotEmpty ||
          platformIds.isNotEmpty ||
          minRating != null ||
          maxRating != null ||
          minUserRating != null ||
          maxUserRating != null ||
          releaseDateFrom != null ||
          releaseDateTo != null ||
          addedDateFrom != null ||
          addedDateTo != null ||
          releaseYears.isNotEmpty;

  bool get hasGenreFilter => genreIds.isNotEmpty;
  bool get hasPlatformFilter => platformIds.isNotEmpty;
  bool get hasGameRatingFilter => minRating != null || maxRating != null;
  bool get hasUserRatingFilter => minUserRating != null || maxUserRating != null;
  bool get hasReleaseDateFilter => releaseDateFrom != null || releaseDateTo != null;
  bool get hasAddedDateFilter => addedDateFrom != null || addedDateTo != null;

  UserCollectionFilters copyWith({
    List<int>? genreIds,
    List<int>? platformIds,
    double? minRating,
    double? maxRating,
    double? minUserRating,
    double? maxUserRating,
    DateTime? releaseDateFrom,
    DateTime? releaseDateTo,
    DateTime? addedDateFrom,
    DateTime? addedDateTo,
    List<int>? releaseYears,
    UserCollectionSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return UserCollectionFilters(
      genreIds: genreIds ?? this.genreIds,
      platformIds: platformIds ?? this.platformIds,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      minUserRating: minUserRating ?? this.minUserRating,
      maxUserRating: maxUserRating ?? this.maxUserRating,
      releaseDateFrom: releaseDateFrom ?? this.releaseDateFrom,
      releaseDateTo: releaseDateTo ?? this.releaseDateTo,
      addedDateFrom: addedDateFrom ?? this.addedDateFrom,
      addedDateTo: addedDateTo ?? this.addedDateTo,
      releaseYears: releaseYears ?? this.releaseYears,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  UserCollectionFilters clearFilters() {
    return UserCollectionFilters(
      sortBy: sortBy, // Keep current sorting
      sortOrder: sortOrder,
    );
  }

  // Get appropriate filters for collection type
  static UserCollectionFilters forWishlist() {
    return const UserCollectionFilters(
      
    );
  }

  static UserCollectionFilters forRated() {
    return const UserCollectionFilters(
      sortBy: UserCollectionSortBy.rating,
    );
  }

  static UserCollectionFilters forRecommended() {
    return const UserCollectionFilters(
      
    );
  }

  @override
  List<Object?> get props => [
    genreIds,
    platformIds,
    minRating,
    maxRating,
    minUserRating,
    maxUserRating,
    releaseDateFrom,
    releaseDateTo,
    addedDateFrom,
    addedDateTo,
    releaseYears,
    sortBy,
    sortOrder,
  ];
}

