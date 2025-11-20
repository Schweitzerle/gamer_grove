// ===== POPULARITY TYPE MODEL =====
// lib/data/models/popularity/popularity_type_model.dart
import 'package:gamer_grove/domain/entities/popularity/popularity_primitive.dart';
import 'package:gamer_grove/domain/entities/popularity/popularity_type.dart';

class PopularityTypeModel extends PopularityType {
  const PopularityTypeModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.createdAt,
    super.updatedAt,
    super.externalPopularitySourceId,
    super.popularitySourceEnum,
  });

  // Factory method for creating common popularity types
  factory PopularityTypeModel.userRating({
    required int id,
    required String checksum,
    PopularitySourceEnum? source,
  }) {
    return PopularityTypeModel(
      id: id,
      checksum: checksum,
      name: 'User Rating',
      popularitySourceEnum: source,
      createdAt: DateTime.now(),
    );
  }

  factory PopularityTypeModel.wishlist({
    required int id,
    required String checksum,
    PopularitySourceEnum? source,
  }) {
    return PopularityTypeModel(
      id: id,
      checksum: checksum,
      name: 'Wishlist',
      popularitySourceEnum: source,
      createdAt: DateTime.now(),
    );
  }

  factory PopularityTypeModel.following({
    required int id,
    required String checksum,
    PopularitySourceEnum? source,
  }) {
    return PopularityTypeModel(
      id: id,
      checksum: checksum,
      name: 'Following',
      popularitySourceEnum: source,
      createdAt: DateTime.now(),
    );
  }

  factory PopularityTypeModel.views({
    required int id,
    required String checksum,
    PopularitySourceEnum? source,
  }) {
    return PopularityTypeModel(
      id: id,
      checksum: checksum,
      name: 'Views',
      popularitySourceEnum: source,
      createdAt: DateTime.now(),
    );
  }

  factory PopularityTypeModel.downloads({
    required int id,
    required String checksum,
    PopularitySourceEnum? source,
  }) {
    return PopularityTypeModel(
      id: id,
      checksum: checksum,
      name: 'Downloads',
      popularitySourceEnum: source,
      createdAt: DateTime.now(),
    );
  }

  factory PopularityTypeModel.fromJson(Map<String, dynamic> json) {
    return PopularityTypeModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      externalPopularitySourceId: json['external_popularity_source'],
      popularitySourceEnum: _parsePopularitySourceEnum(json['popularity_source']),
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

  static PopularitySourceEnum? _parsePopularitySourceEnum(dynamic source) {
    if (source is int) {
      return PopularitySourceEnum.fromValue(source);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'external_popularity_source': externalPopularitySourceId,
      'popularity_source': popularitySourceEnum?.value,
    };
  }
}