import 'package:gamer_grove/domain/entities/collection/user_collection.dart';

/// Maps `user_collections` rows (with an optional embedded game count) to and
/// from the [UserCollection] domain entity.
abstract final class UserCollectionModel {
  /// Builds a [UserCollection] from a PostgREST row.
  ///
  /// When the query embeds `user_collection_games(count)`, PostgREST returns a
  /// nested list like `[{ "count": 3 }]`; the game count reads that shape and
  /// falls back to 0.
  static UserCollection fromJson(Map<String, dynamic> json) {
    return UserCollection(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverGameId: json['cover_game_id'] as int?,
      isPublic: json['is_public'] as bool? ?? false,
      gameCount: _gameCount(json),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static int _gameCount(Map<String, dynamic> json) {
    final embedded = json['user_collection_games'];
    if (embedded is List && embedded.isNotEmpty) {
      final first = embedded.first;
      if (first is Map<String, dynamic>) {
        return (first['count'] as num?)?.toInt() ?? 0;
      }
    }
    return 0;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
