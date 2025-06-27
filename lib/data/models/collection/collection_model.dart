// lib/data/models/collection_model.dart

import '../../../domain/entities/collection.dart';

class CollectionModel extends Collection {
  const CollectionModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.slug,
    super.url,
    super.asChildRelationIds = const [],
    super.asParentRelationIds = const [],
    super.gameIds = const [],
    super.typeId,
    super.createdAt,
    super.updatedAt,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      url: json['url'],
      asChildRelationIds: _parseIdList(json['as_child_relations']),
      asParentRelationIds: _parseIdList(json['as_parent_relations']),
      gameIds: _parseIdList(json['games']),
      typeId: json['type'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static List<int> _parseIdList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is int || (item is Map && item['id'] is int))
          .map((item) => item is int ? item : item['id'] as int)
          .toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'name': name,
      'slug': slug,
      'url': url,
      'as_child_relations': asChildRelationIds,
      'as_parent_relations': asParentRelationIds,
      'games': gameIds,
      'type': typeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}