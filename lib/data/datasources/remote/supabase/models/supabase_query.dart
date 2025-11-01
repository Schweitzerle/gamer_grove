/// Query builder for Supabase database operations.
///
/// Provides a fluent interface for building type-safe queries.
library;

import 'package:supabase_flutter/supabase_flutter.dart' hide SortBy;
import 'supabase_filters.dart';

/// Builder class for constructing Supabase queries with a fluent API.
///
/// Example:
/// ```dart
/// final query = SupabaseQuery('users')
///   .select('id, username, avatar_url')
///   .filter(EqualFilter('is_profile_public', true))
///   .sort(SortBy('followers_count', SortOrder.descending))
///   .paginate(Pagination(limit: 20))
///   .build(supabase);
///
/// final result = await query;
/// ```
class SupabaseQuery {
  final String table;
  String? _selectColumns;
  final List<SupabaseFilter> _filters = [];
  SortBy? _sortBy;
  Pagination? _pagination;
  int? _single;

  SupabaseQuery(this.table);

  /// Specifies which columns to select.
  ///
  /// Example:
  /// ```dart
  /// query.select('id, username, avatar_url')
  /// query.select('*') // Select all columns
  /// ```
  SupabaseQuery select(String columns) {
    _selectColumns = columns;
    return this;
  }

  /// Adds a filter to the query.
  ///
  /// Multiple filters can be chained and will be combined with AND logic.
  ///
  /// Example:
  /// ```dart
  /// query
  ///   .filter(EqualFilter('is_profile_public', true))
  ///   .filter(GreaterThanFilter('followers_count', 100))
  /// ```
  SupabaseQuery filter(SupabaseFilter filter) {
    _filters.add(filter);
    return this;
  }

  /// Adds multiple filters at once.
  ///
  /// Example:
  /// ```dart
  /// query.filters([
  ///   EqualFilter('is_profile_public', true),
  ///   GreaterThanFilter('followers_count', 100),
  /// ])
  /// ```
  SupabaseQuery filters(List<SupabaseFilter> filters) {
    _filters.addAll(filters);
    return this;
  }

  /// Adds sorting to the query.
  ///
  /// Example:
  /// ```dart
  /// query.sort(SortBy('created_at', SortOrder.descending))
  /// ```
  SupabaseQuery sort(SortBy sortBy) {
    _sortBy = sortBy;
    return this;
  }

  /// Adds pagination to the query.
  ///
  /// Example:
  /// ```dart
  /// query.paginate(Pagination(limit: 20, offset: 40))
  /// query.paginate(Pagination.page(2, pageSize: 20))
  /// ```
  SupabaseQuery paginate(Pagination pagination) {
    _pagination = pagination;
    return this;
  }

  /// Expects exactly one result.
  ///
  /// Will throw an error if no results or multiple results are found.
  ///
  /// Example:
  /// ```dart
  /// query.single()
  /// ```
  SupabaseQuery single() {
    _single = 1;
    return this;
  }

  /// Expects zero or one result.
  ///
  /// Returns null if no results found, throws error if multiple results.
  ///
  /// Example:
  /// ```dart
  /// query.maybeSingle()
  /// ```
  SupabaseQuery maybeSingle() {
    _single = 0;
    return this;
  }

  /// Builds and executes the query.
  ///
  /// Returns a Future that resolves to the query results.
  ///
  /// Example:
  /// ```dart
  /// final users = await query.build(supabase);
  /// ```
  Future<dynamic> build(SupabaseClient supabase) async {
    // Start with the table and select
    dynamic queryBuilder = supabase.from(table).select(_selectColumns ?? '*');

    // Apply filters
    for (final filter in _filters) {
      final params = filter.toQueryParams();
      params.forEach((column, value) {
        // Handle special operators
        if (column.endsWith('_gt')) {
          queryBuilder = queryBuilder.gt(column.replaceAll('_gt', ''), value);
        } else if (column.endsWith('_gte')) {
          queryBuilder = queryBuilder.gte(column.replaceAll('_gte', ''), value);
        } else if (column.endsWith('_lt')) {
          queryBuilder = queryBuilder.lt(column.replaceAll('_lt', ''), value);
        } else if (column.endsWith('_lte')) {
          queryBuilder = queryBuilder.lte(column.replaceAll('_lte', ''), value);
        } else if (column.endsWith('_like')) {
          queryBuilder =
              queryBuilder.like(column.replaceAll('_like', ''), value);
        } else if (column.endsWith('_ilike')) {
          queryBuilder =
              queryBuilder.ilike(column.replaceAll('_ilike', ''), value);
        } else if (column.endsWith('_is')) {
          queryBuilder =
              queryBuilder.isFilter(column.replaceAll('_is', ''), value);
        } else if (column.endsWith('_not.is')) {
          queryBuilder =
              queryBuilder.not(column.replaceAll('_not.is', ''), 'is', value);
        } else if (value is List) {
          queryBuilder = queryBuilder.inFilter(column, value);
        } else {
          queryBuilder = queryBuilder.eq(column, value);
        }
      });
    }

    // Apply sorting
    if (_sortBy != null) {
      queryBuilder = queryBuilder.order(
        _sortBy!.column,
        ascending: _sortBy!.order.ascending,
      );
    }

    // Apply pagination
    if (_pagination != null) {
      queryBuilder = queryBuilder.range(
        _pagination!.offset,
        _pagination!.offset + _pagination!.limit - 1,
      );
    }

    // Apply single/maybeSingle and await the result
    if (_single != null) {
      if (_single == 1) {
        return await queryBuilder.single();
      } else {
        return await queryBuilder.maybeSingle();
      }
    }

    // For list queries, await the result
    return await queryBuilder;
  }

  @override
  String toString() {
    final buffer = StringBuffer('SupabaseQuery($table)');
    if (_selectColumns != null) buffer.write(' SELECT $_selectColumns');
    if (_filters.isNotEmpty) buffer.write(' WHERE ${_filters.length} filters');
    if (_sortBy != null) buffer.write(' ORDER BY $_sortBy');
    if (_pagination != null) buffer.write(' $_pagination');
    if (_single != null) buffer.write(' SINGLE');
    return buffer.toString();
  }
}

/// Builder for RPC (Remote Procedure Call) queries.
///
/// Used for calling PostgreSQL functions directly.
///
/// Example:
/// ```dart
/// final result = await SupabaseRpcQuery('get_user_game_enrichment_data')
///   .param('p_user_id', userId)
///   .param('p_game_ids', [1942, 1905, 113])
///   .build(supabase);
/// ```
class SupabaseRpcQuery {
  final String functionName;
  final Map<String, dynamic> _params = {};

  SupabaseRpcQuery(this.functionName);

  /// Adds a parameter to the RPC call.
  ///
  /// Example:
  /// ```dart
  /// query
  ///   .param('p_user_id', 'uuid-here')
  ///   .param('p_game_ids', [1, 2, 3])
  /// ```
  SupabaseRpcQuery param(String name, dynamic value) {
    _params[name] = value;
    return this;
  }

  /// Adds multiple parameters at once.
  ///
  /// Example:
  /// ```dart
  /// query.params({
  ///   'p_user_id': 'uuid-here',
  ///   'p_game_ids': [1, 2, 3],
  /// })
  /// ```
  SupabaseRpcQuery params(Map<String, dynamic> params) {
    _params.addAll(params);
    return this;
  }

  /// Builds and executes the RPC query.
  ///
  /// Returns a Future that resolves to the function results.
  ///
  /// Example:
  /// ```dart
  /// final enrichedData = await query.build(supabase);
  /// ```
  Future<dynamic> build(SupabaseClient supabase) {
    return supabase.rpc(functionName, params: _params);
  }

  @override
  String toString() {
    return 'SupabaseRpcQuery($functionName) with ${_params.length} params';
  }
}

/// Builder for insert operations.
///
/// Example:
/// ```dart
/// await SupabaseInsert('users')
///   .values({
///     'id': userId,
///     'username': 'john_doe',
///     'display_name': 'John Doe',
///   })
///   .returning('id, username')
///   .build(supabase);
/// ```
class SupabaseInsert {
  final String table;
  Map<String, dynamic>? _values;
  List<Map<String, dynamic>>? _multipleValues;
  String? _returning;
  bool _upsert = false;

  SupabaseInsert(this.table);

  /// Sets the values to insert (single row).
  ///
  /// Example:
  /// ```dart
  /// insert.values({'username': 'john', 'email': 'john@example.com'})
  /// ```
  SupabaseInsert values(Map<String, dynamic> values) {
    _values = values;
    return this;
  }

  /// Sets multiple rows to insert.
  ///
  /// Example:
  /// ```dart
  /// insert.multipleValues([
  ///   {'username': 'john', 'email': 'john@example.com'},
  ///   {'username': 'jane', 'email': 'jane@example.com'},
  /// ])
  /// ```
  SupabaseInsert multipleValues(List<Map<String, dynamic>> values) {
    _multipleValues = values;
    return this;
  }

  /// Specifies which columns to return after insert.
  ///
  /// Example:
  /// ```dart
  /// insert.returning('id, created_at')
  /// ```
  SupabaseInsert returning(String columns) {
    _returning = columns;
    return this;
  }

  /// Enables upsert mode (insert or update if exists).
  ///
  /// Example:
  /// ```dart
  /// insert.upsert()
  /// ```
  SupabaseInsert upsert() {
    _upsert = true;
    return this;
  }

  /// Builds and executes the insert operation.
  Future<dynamic> build(SupabaseClient supabase) async {
    final data = _multipleValues ?? _values;
    if (data == null) {
      throw ArgumentError('No values provided for insert');
    }

    dynamic query;
    if (_upsert) {
      query = supabase.from(table).upsert(data);
    } else {
      query = supabase.from(table).insert(data);
    }

    if (_returning != null) {
      return await query.select(_returning!);
    }

    // Execute the query and return the result
    return await query.select();
  }

  @override
  String toString() {
    final rowCount = _multipleValues?.length ?? 1;
    return 'SupabaseInsert($table) $rowCount row(s)${_upsert ? ' (UPSERT)' : ''}';
  }
}

/// Builder for update operations.
///
/// Example:
/// ```dart
/// await SupabaseUpdate('users')
///   .set({'display_name': 'New Name'})
///   .filter(EqualFilter('id', userId))
///   .returning('updated_at')
///   .build(supabase);
/// ```
class SupabaseUpdate {
  final String table;
  Map<String, dynamic>? _values;
  final List<SupabaseFilter> _filters = [];
  String? _returning;

  SupabaseUpdate(this.table);

  /// Sets the values to update.
  ///
  /// Example:
  /// ```dart
  /// update.set({'username': 'new_username', 'bio': 'New bio'})
  /// ```
  SupabaseUpdate set(Map<String, dynamic> values) {
    _values = values;
    return this;
  }

  /// Adds a filter to specify which rows to update.
  ///
  /// Example:
  /// ```dart
  /// update.filter(EqualFilter('id', userId))
  /// ```
  SupabaseUpdate filter(SupabaseFilter filter) {
    _filters.add(filter);
    return this;
  }

  /// Specifies which columns to return after update.
  ///
  /// Example:
  /// ```dart
  /// update.returning('id, updated_at')
  /// ```
  SupabaseUpdate returning(String columns) {
    _returning = columns;
    return this;
  }

  /// Builds and executes the update operation.
  Future<dynamic> build(SupabaseClient supabase) async {
    if (_values == null || _values!.isEmpty) {
      throw ArgumentError('No values provided for update');
    }

    var query = supabase.from(table).update(_values!);

    // Apply filters
    for (final filter in _filters) {
      final params = filter.toQueryParams();
      params.forEach((column, value) {
        if (value is List) {
          query = query.inFilter(column, value);
        } else {
          query = query.eq(column, value);
        }
      });
    }

    if (_returning != null) {
      return query.select(_returning!);
    }

    // Execute the query and return the result
    return await query.select();
  }

  @override
  String toString() {
    return 'SupabaseUpdate($table) SET ${_values?.length ?? 0} fields WHERE ${_filters.length} filters';
  }
}

/// Builder for delete operations.
///
/// Example:
/// ```dart
/// await SupabaseDelete('user_follows')
///   .filter(EqualFilter('follower_id', userId))
///   .filter(EqualFilter('following_id', targetUserId))
///   .build(supabase);
/// ```
class SupabaseDelete {
  final String table;
  final List<SupabaseFilter> _filters = [];
  String? _returning;

  SupabaseDelete(this.table);

  /// Adds a filter to specify which rows to delete.
  ///
  /// Example:
  /// ```dart
  /// delete.filter(EqualFilter('id', itemId))
  /// ```
  SupabaseDelete filter(SupabaseFilter filter) {
    _filters.add(filter);
    return this;
  }

  /// Specifies which columns to return after deletion.
  ///
  /// Example:
  /// ```dart
  /// delete.returning('id')
  /// ```
  SupabaseDelete returning(String columns) {
    _returning = columns;
    return this;
  }

  /// Builds and executes the delete operation.
  Future<dynamic> build(SupabaseClient supabase) async {
    if (_filters.isEmpty) {
      throw ArgumentError(
          'No filters provided for delete - this would delete all rows!');
    }

    var query = supabase.from(table).delete();

    // Apply filters
    for (final filter in _filters) {
      final params = filter.toQueryParams();
      params.forEach((column, value) {
        if (value is List) {
          query = query.inFilter(column, value);
        } else {
          query = query.eq(column, value);
        }
      });
    }

    if (_returning != null) {
      return query.select(_returning!);
    }

    // Execute the query and return the result
    return await query.select();
  }

  @override
  String toString() {
    return 'SupabaseDelete($table) WHERE ${_filters.length} filters';
  }
}
