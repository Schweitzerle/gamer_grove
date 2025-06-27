
// lib/data/models/collection_membership_type_model.dart

import '../../../domain/entities/collection/collection_membership_type.dart';

class CollectionMembershipTypeModel extends CollectionMembershipType {
  const CollectionMembershipTypeModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.description,
    super.allowedCollectionTypeId,
    super.createdAt,
    super.updatedAt,
  });

  factory CollectionMembershipTypeModel.fromJson(Map<String, dynamic> json) {
    return CollectionMembershipTypeModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      allowedCollectionTypeId: json['allowed_collection_type'],
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
      'allowed_collection_type': allowedCollectionTypeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
