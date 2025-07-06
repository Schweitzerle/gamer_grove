// ===== UPDATED AGE RATING ORGANIZATION MODEL =====
// lib/data/models/ageRating/age_rating_organization_model.dart
import '../../../domain/entities/ageRating/age_rating_organization.dart';

class AgeRatingOrganizationModel extends AgeRatingOrganization {
  const AgeRatingOrganizationModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.createdAt,
    super.updatedAt,
  });

  factory AgeRatingOrganizationModel.fromJson(Map<String, dynamic> json) {
    return AgeRatingOrganizationModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
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
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}