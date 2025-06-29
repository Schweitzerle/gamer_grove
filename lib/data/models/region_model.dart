// ===== REGION MODEL =====
// File: lib/data/models/region_model.dart

import '../../domain/entities/region.dart';

class RegionModel extends Region {
  const RegionModel({
    required super.id,
    required super.checksum,
    required super.category,
    required super.identifier,
    required super.name,
    super.createdAt,
    super.updatedAt,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      category: json['category'] ?? 'locale',
      identifier: json['identifier'] ?? '',
      name: json['name'] ?? '',
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
      'category': category,
      'identifier': identifier,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Factory for creating from legacy enum
  factory RegionModel.fromEnum(RegionEnum regionEnum) {
    return RegionModel(
      id: regionEnum.value,
      checksum: '',
      category: 'locale',
      identifier: regionEnum.name.toUpperCase(),
      name: regionEnum.displayName,
    );
  }
}



