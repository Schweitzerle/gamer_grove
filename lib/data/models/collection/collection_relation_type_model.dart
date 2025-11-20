// lib/data/models/collection_relation_type_model.dart

import 'package:gamer_grove/domain/entities/collection/collection_relation_type.dart';

class CollectionRelationTypeModel extends CollectionRelationType {
  const CollectionRelationTypeModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.description,
    super.allowedChildTypeId,
    super.allowedParentTypeId,
    super.createdAt,
    super.updatedAt,
  });

  factory CollectionRelationTypeModel.fromJson(Map<String, dynamic> json) {
    return CollectionRelationTypeModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      allowedChildTypeId: json['allowed_child_type'],
      allowedParentTypeId: json['allowed_parent_type'],
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
      'name': name,
      'description': description,
      'allowed_child_type': allowedChildTypeId,
      'allowed_parent_type': allowedParentTypeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}