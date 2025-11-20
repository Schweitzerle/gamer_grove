// ===== RELEASE DATE STATUS MODEL =====
// lib/data/models/release_date/release_date_status_model.dart
import 'package:gamer_grove/domain/entities/releaseDate/release_date_status.dart';

class ReleaseDateStatusModel extends ReleaseDateStatus {
  const ReleaseDateStatusModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
  });

  factory ReleaseDateStatusModel.fromJson(Map<String, dynamic> json) {
    return ReleaseDateStatusModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}