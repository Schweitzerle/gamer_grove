// lib/data/models/website_type_model.dart
import '../../../domain/entities/website/website_type.dart';

class WebsiteTypeModel extends WebsiteType {
  const WebsiteTypeModel({
    required super.id,
    required super.checksum,
    required super.type,
    super.createdAt,
    super.updatedAt,
  });

  factory WebsiteTypeModel.fromJson(Map<String, dynamic> json) {
    return WebsiteTypeModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      type: json['type'] ?? 'unknown',
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
      'type': type,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper factory for creating from category enum (legacy support)
  factory WebsiteTypeModel.fromCategory(WebsiteCategory category) {
    return WebsiteTypeModel(
      id: category.value,
      checksum: '',
      type: category.typeName,
    );
  }
}