// lib/data/models/collection_membership_model.dart

import '../../../domain/entities/collection/collection_membership.dart';

class CollectionMembershipModel extends CollectionMembership {
  const CollectionMembershipModel({
    required super.id,
    required super.checksum,
    super.collectionId,
    super.gameId,
    super.typeId,
    super.createdAt,
    super.updatedAt,
  });

  factory CollectionMembershipModel.fromJson(Map<String, dynamic> json) {
    return CollectionMembershipModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      collectionId: json['collection'],
      gameId: json['game'],
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
      'collection': collectionId,
      'game': gameId,
      'type': typeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
