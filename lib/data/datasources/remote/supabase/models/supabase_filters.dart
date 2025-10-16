/// Defines various filter types for Supabase queries.
///
/// This file provides type-safe filter classes for building complex
/// queries with the Supabase database.
library;

/// Base class for all Supabase filters.
///
/// Provides a common interface for converting filters to query parameters.
abstract class SupabaseFilter {
  /// Converts this filter to a map of query parameters.
  ///
  /// Returns a map where keys are column names and values are the filter values.
  Map<String, dynamic> toQueryParams();
}

/// Filter for exact equality matches.
///
/// Example:
/// ```dart
/// final filter = EqualFilter('username', 'john_doe');
/// // Generates: WHERE username = 'john_doe'
/// ```
class EqualFilter implements SupabaseFilter {
  final String column;
  final dynamic value;

  const EqualFilter(this.column, this.value);

  @override
  Map<String, dynamic> toQueryParams() => {column: value};

  @override
  String toString() => 'EqualFilter($column = $value)';
}

/// Filter for checking if a value is in a list.
///
/// Example:
/// ```dart
/// final filter = InFilter('game_id', [1942, 1905, 113]);
/// // Generates: WHERE game_id IN (1942, 1905, 113)
/// ```
class InFilter implements SupabaseFilter {
  final String column;
  final List<dynamic> values;

  const InFilter(this.column, this.values);

  @override
  Map<String, dynamic> toQueryParams() => {column: values};

  @override
  String toString() => 'InFilter($column IN ${values.length} values)';
}

/// Filter for greater than comparisons.
///
/// Example:
/// ```dart
/// final filter = GreaterThanFilter('rating', 8.0);
/// // Generates: WHERE rating > 8.0
/// ```
class GreaterThanFilter implements SupabaseFilter {
  final String column;
  final dynamic value;

  const GreaterThanFilter(this.column, this.value);

  @override
  Map<String, dynamic> toQueryParams() => {'${column}_gt': value};

  @override
  String toString() => 'GreaterThanFilter($column > $value)';
}

/// Filter for greater than or equal comparisons.
///
/// Example:
/// ```dart
/// final filter = GreaterThanOrEqualFilter('rating', 8.0);
/// // Generates: WHERE rating >= 8.0
/// ```
class GreaterThanOrEqualFilter implements SupabaseFilter {
  final String column;
  final dynamic value;

  const GreaterThanOrEqualFilter(this.column, this.value);

  @override
  Map<String, dynamic> toQueryParams() => {'${column}_gte': value};

  @override
  String toString() => 'GreaterThanOrEqualFilter($column >= $value)';
}

/// Filter for less than comparisons.
///
/// Example:
/// ```dart
/// final filter = LessThanFilter('followers_count', 1000);
/// // Generates: WHERE followers_count < 1000
/// ```
class LessThanFilter implements SupabaseFilter {
  final String column;
  final dynamic value;

  const LessThanFilter(this.column, this.value);

  @override
  Map<String, dynamic> toQueryParams() => {'${column}_lt': value};

  @override
  String toString() => 'LessThanFilter($column < $value)';
}

/// Filter for less than or equal comparisons.
///
/// Example:
/// ```dart
/// final filter = LessThanOrEqualFilter('followers_count', 1000);
/// // Generates: WHERE followers_count <= 1000
/// ```
class LessThanOrEqualFilter implements SupabaseFilter {
  final String column;
  final dynamic value;

  const LessThanOrEqualFilter(this.column, this.value);

  @override
  Map<String, dynamic> toQueryParams() => {'${column}_lte': value};

  @override
  String toString() => 'LessThanOrEqualFilter($column <= $value)';
}

/// Filter for pattern matching using LIKE.
///
/// Example:
/// ```dart
/// final filter = LikeFilter('username', '%john%');
/// // Generates: WHERE username LIKE '%john%'
/// ```
class LikeFilter implements SupabaseFilter {
  final String column;
  final String pattern;

  const LikeFilter(this.column, this.pattern);

  @override
  Map<String, dynamic> toQueryParams() => {'${column}_like': pattern};

  @override
  String toString() => 'LikeFilter($column LIKE $pattern)';
}

/// Filter for case-insensitive pattern matching using ILIKE.
///
/// Example:
/// ```dart
/// final filter = ILikeFilter('username', '%JOHN%');
/// // Generates: WHERE username ILIKE '%JOHN%'
/// ```
class ILikeFilter implements SupabaseFilter {
  final String column;
  final String pattern;

  const ILikeFilter(this.column, this.pattern);

  @override
  Map<String, dynamic> toQueryParams() => {'${column}_ilike': pattern};

  @override
  String toString() => 'ILikeFilter($column ILIKE $pattern)';
}

/// Filter for checking if a value is null.
///
/// Example:
/// ```dart
/// final filter = IsNullFilter('bio');
/// // Generates: WHERE bio IS NULL
/// ```
class IsNullFilter implements SupabaseFilter {
  final String column;

  const IsNullFilter(this.column);

  @override
  Map<String, dynamic> toQueryParams() => {'${column}_is': null};

  @override
  String toString() => 'IsNullFilter($column IS NULL)';
}

/// Filter for checking if a value is not null.
///
/// Example:
/// ```dart
/// final filter = NotNullFilter('avatar_url');
/// // Generates: WHERE avatar_url IS NOT NULL
/// ```
class NotNullFilter implements SupabaseFilter {
  final String column;

  const NotNullFilter(this.column);

  @override
  Map<String, dynamic> toQueryParams() => {'${column}_not.is': null};

  @override
  String toString() => 'NotNullFilter($column IS NOT NULL)';
}

/// Filter for boolean true values.
///
/// Example:
/// ```dart
/// final filter = IsTrueFilter('is_profile_public');
/// // Generates: WHERE is_profile_public = true
/// ```
class IsTrueFilter implements SupabaseFilter {
  final String column;

  const IsTrueFilter(this.column);

  @override
  Map<String, dynamic> toQueryParams() => {column: true};

  @override
  String toString() => 'IsTrueFilter($column = true)';
}

/// Filter for boolean false values.
///
/// Example:
/// ```dart
/// final filter = IsFalseFilter('is_profile_public');
/// // Generates: WHERE is_profile_public = false
/// ```
class IsFalseFilter implements SupabaseFilter {
  final String column;

  const IsFalseFilter(this.column);

  @override
  Map<String, dynamic> toQueryParams() => {column: false};

  @override
  String toString() => 'IsFalseFilter($column = false)';
}

/// Filter for combining multiple filters with AND logic.
///
/// Example:
/// ```dart
/// final filter = AndFilter([
///   EqualFilter('is_profile_public', true),
///   GreaterThanFilter('followers_count', 100),
/// ]);
/// // Generates: WHERE is_profile_public = true AND followers_count > 100
/// ```
class AndFilter implements SupabaseFilter {
  final List<SupabaseFilter> filters;

  const AndFilter(this.filters);

  @override
  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    for (final filter in filters) {
      params.addAll(filter.toQueryParams());
    }
    return params;
  }

  @override
  String toString() => 'AndFilter(${filters.length} filters)';
}

/// Sorting order enum.
enum SortOrder {
  asc,
  desc;

  /// Converts the sort order to Supabase format.
  bool get ascending => this == SortOrder.asc;

  String toSupabaseString() => ascending ? 'asc' : 'desc';
}

/// Sort configuration for queries.
///
/// Example:
/// ```dart
/// final sort = SortBy('created_at', SortOrder.descending);
/// ```
class SortBy {
  final String column;
  final SortOrder order;

  const SortBy(this.column, this.order);

  /// Converts to Supabase query parameters.
  Map<String, dynamic> toQueryParams() => {
        'order': column,
        'ascending': order.ascending,
      };

  @override
  String toString() => 'SortBy($column ${order.toSupabaseString()})';
}

/// Pagination configuration for queries.
///
/// Example:
/// ```dart
/// final pagination = Pagination(limit: 20, offset: 40);
/// ```
class Pagination {
  final int limit;
  final int offset;

  const Pagination({
    required this.limit,
    this.offset = 0,
  });

  /// Creates pagination for a specific page number.
  ///
  /// Example:
  /// ```dart
  /// final page2 = Pagination.page(2, pageSize: 20); // offset: 20, limit: 20
  /// ```
  factory Pagination.page(int page, {required int pageSize}) {
    return Pagination(
      limit: pageSize,
      offset: (page - 1) * pageSize,
    );
  }

  /// Converts to Supabase query parameters.
  Map<String, dynamic> toQueryParams() => {
        'limit': limit,
        'offset': offset,
      };

  @override
  String toString() => 'Pagination(limit: $limit, offset: $offset)';
}
