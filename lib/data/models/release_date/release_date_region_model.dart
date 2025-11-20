// ===== RELEASE DATE REGION MODEL =====
// lib/data/models/release_date/release_date_region_model.dart

import 'package:gamer_grove/domain/entities/releaseDate/release_date_region.dart';

class ReleaseDateRegionModel extends ReleaseDateRegion {
  const ReleaseDateRegionModel({
    required super.id,
    required super.checksum,
    required super.region,
    super.createdAt,
    super.updatedAt,
  });

  factory ReleaseDateRegionModel.fromJson(Map<String, dynamic> json) {
    return ReleaseDateRegionModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      region: json['region'] ?? '',
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
      'region': region,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

