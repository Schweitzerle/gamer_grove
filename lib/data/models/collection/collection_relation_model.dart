// lib/data/models/collection_relation_model.dart

import 'package:gamer_grove/domain/entities/collection/collection_relation.dart';

class CollectionRelationModel extends CollectionRelation {
  const CollectionRelationModel({
    required super.id,
    required super.checksum,
    super.childCollectionId,
    super.parentCollectionId,
    super.typeId,
    super.createdAt,
    super.updatedAt,
  });

  factory CollectionRelationModel.fromJson(Map<String, dynamic> json) {
    return CollectionRelationModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      childCollectionId: json['child_collection'],
      parentCollectionId: json['parent_collection'],
      typeId: json['type'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
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
      'child_collection': childCollectionId,
      'parent_collection': parentCollectionId,
      'type': typeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

