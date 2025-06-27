// lib/data/models/age_rating_category_model.dart
import '../../../domain/entities/ageRating/age_rating_category.dart';

class AgeRatingCategoryModel extends AgeRatingCategory {
  const AgeRatingCategoryModel({
    required super.id,
    required super.checksum,
    required super.rating,
    super.organizationId,
    super.createdAt,
    super.updatedAt,
  });

  factory AgeRatingCategoryModel.fromJson(Map<String, dynamic> json) {
    return AgeRatingCategoryModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      rating: json['rating'] ?? '',
      organizationId: json['organization'],
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
      'rating': rating,
      'organization': organizationId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}