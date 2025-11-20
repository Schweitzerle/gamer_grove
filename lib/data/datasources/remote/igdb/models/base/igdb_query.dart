// lib/data/datasources/remote/igdb/models/base/igdb_query.dart

import 'package:equatable/equatable.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart';

/// Generic base class for all IGDB API queries.
///
/// This class encapsulates all parts of an IGDB query:
/// - WHERE clause (filtering)
/// - FIELDS selection
/// - LIMIT and OFFSET (pagination)
/// - SORT ordering
/// - EXCLUDE clause
///
/// Type parameter [T] represents the model type being queried.
///
/// Example:
/// ```dart
/// final query = IgdbQuery<GameModel>(
///   where: GameFilters.byPlatform(6),
///   fields: ['name', 'cover.url', 'total_rating'],
///   limit: 20,
///   offset: 0,
///   sort: 'total_rating desc',
/// );
///
/// final queryString = query.buildQuery();
/// ```
class IgdbQuery<T> extends Equatable {

  const IgdbQuery({
    this.search,
    this.where,
    this.fields = const ['*'],
    this.limit = 20,
    this.offset = 0,
    this.sort,
    this.exclude,
  });
  /// Search term for IGDB's search endpoint
  /// Use this instead of 'where name ~' for better search results
  final String? search;

  /// Filter condition for the WHERE clause
  final IgdbFilter? where;

  /// Fields to retrieve. Use '*' for all fields.
  /// For nested fields, use dot notation: 'cover.url'
  final List<String> fields;

  /// Maximum number of results to return
  final int limit;

  /// Number of results to skip (for pagination)
  final int offset;

  /// Sort order. Format: 'field_name asc/desc'
  /// Examples: 'name asc', 'total_rating desc'
  final String? sort;

  /// Fields to exclude from the response
  final List<String>? exclude;

  /// Builds the complete IGDB query string
  String buildQuery() {
    final parts = <String>[];

    // Search clause (optional)
    if (search != null && search!.isNotEmpty) {
      parts.add('search "$search"; ');
    }

    // Fields clause (required)
    parts.add('fields ${fields.join(',')}; ');

    // Where clause (optional, can be combined with search!)
    // IGDB allows both search and where to be used together
    if (where != null) {
      parts.add('where ${where!.toQueryString()}; ');
    }

    // Limit clause (required)
    parts.add('limit $limit; ');

    // Offset clause (required)
    parts.add('offset $offset; ');

    // Sort clause (optional)
    if (sort != null && sort!.isNotEmpty) {
      parts.add('sort $sort; ');
    }

    // Exclude clause (optional)
    if (exclude != null && exclude!.isNotEmpty) {
      parts.add('exclude ${exclude!.join(',')}; ');
    }

    return parts.join();
  }

  /// Creates a copy of this query with modified parameters
  IgdbQuery<T> copyWith({
    String? search,
    IgdbFilter? where,
    List<String>? fields,
    int? limit,
    int? offset,
    String? sort,
    List<String>? exclude,
  }) {
    return IgdbQuery<T>(
      search: search ?? this.search,
      where: where ?? this.where,
      fields: fields ?? this.fields,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      sort: sort ?? this.sort,
      exclude: exclude ?? this.exclude,
    );
  }

  /// Creates a new query for the next page
  IgdbQuery<T> nextPage() {
    return copyWith(offset: offset + limit);
  }

  /// Creates a new query for the previous page
  IgdbQuery<T> previousPage() {
    final newOffset = offset - limit;
    return copyWith(offset: newOffset < 0 ? 0 : newOffset);
  }

  /// Creates a new query for a specific page number (0-indexed)
  IgdbQuery<T> toPage(int pageNumber) {
    return copyWith(offset: pageNumber * limit);
  }

  @override
  List<Object?> get props => [search, where, fields, limit, offset, sort, exclude];

  @override
  String toString() => 'IgdbQuery<$T>(limit: $limit, offset: $offset)';
}

// ============================================================
// TYPE ALIASES FOR ENTITY-SPECIFIC QUERIES
// ============================================================

// NOTE: Import the model types before using these aliases
// These will be defined in the main query file after models are imported

// Example usage after this file:
// typedef IgdbGameQuery = IgdbQuery<GameModel>;
// typedef IgdbCharacterQuery = IgdbQuery<CharacterModel>;
// typedef IgdbPlatformQuery = IgdbQuery<PlatformModel>;

// ============================================================
// GENERIC QUERY BUILDER
// ============================================================

/// Generic fluent builder for constructing IGDB queries step by step.
///
/// Example:
/// ```dart
/// final query = IgdbQueryBuilder<GameModel>()
///   .withFields(['name', 'cover.url', 'rating'])
///   .withFilter(GameFilters.byPlatform(6))
///   .withLimit(20)
///   .sortBy('total_rating desc')
///   .build();
/// ```
class IgdbQueryBuilder<T> {

  IgdbQueryBuilder();

  /// Start from an existing query
  IgdbQueryBuilder.from(IgdbQuery<T> query)
      : _search = query.search,
        _where = query.where,
        _fields = query.fields,
        _limit = query.limit,
        _offset = query.offset,
        _sort = query.sort,
        _exclude = query.exclude;
  String? _search;
  IgdbFilter? _where;
  List<String> _fields = const ['*'];
  int _limit = 20;
  int _offset = 0;
  String? _sort;
  List<String>? _exclude;

  IgdbQueryBuilder<T> withSearch(String? search) {
    _search = search;
    return this;
  }

  IgdbQueryBuilder<T> withFilter(IgdbFilter? filter) {
    _where = filter;
    return this;
  }

  IgdbQueryBuilder<T> withFields(List<String> fields) {
    _fields = fields;
    return this;
  }

  IgdbQueryBuilder<T> withLimit(int limit) {
    _limit = limit;
    return this;
  }

  IgdbQueryBuilder<T> withOffset(int offset) {
    _offset = offset;
    return this;
  }

  IgdbQueryBuilder<T> sortBy(String sort) {
    _sort = sort;
    return this;
  }

  IgdbQueryBuilder<T> exclude(List<String> fields) {
    _exclude = fields;
    return this;
  }

  /// Build the final query
  IgdbQuery<T> build() {
    return IgdbQuery<T>(
      search: _search,
      where: _where,
      fields: _fields,
      limit: _limit,
      offset: _offset,
      sort: _sort,
      exclude: _exclude,
    );
  }
}
