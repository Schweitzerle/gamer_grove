// lib/data/models/collection.dart
import '../../domain/entities/collection.dart';

class CollectionModel extends Collection {
  const CollectionModel({
    required super.id,
    required super.name,
    required super.slug,
    super.url,
    super.gameIds,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Collection',
      slug: json['slug'] ?? json['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? 'unknown',
      url: json['url'],
      gameIds: _parseGameIds(json['games']),
    );
  }

  static List<int> _parseGameIds(dynamic games) {
    if (games is List) {
      return games
          .where((game) => game is Map && game['id'] is int)
          .map((game) => game['id'] as int)
          .toList();
    }
    return [];
  }
}