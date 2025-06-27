// lib/data/models/age_rating_model.dart
import '../../../domain/entities/ageRating/age_rating.dart';

class AgeRatingModel extends AgeRating {
  const AgeRatingModel({
    required super.id,
    required super.checksum,
    super.contentDescriptions,
    super.organizationId,
    super.ratingCategoryId,
    super.ratingContentDescriptions,
    super.ratingCoverUrl,
    super.synopsis,
    super.categoryEnum,
    super.ratingEnum,
  });

  factory AgeRatingModel.fromJson(Map<String, dynamic> json) {
    return AgeRatingModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      contentDescriptions: _parseIdList(json['content_descriptions']),
      organizationId: json['organization'],
      ratingCategoryId: json['rating_category'],
      ratingContentDescriptions: _parseIdList(json['rating_content_descriptions']),
      ratingCoverUrl: json['rating_cover_url'],
      synopsis: json['synopsis'],
      categoryEnum: _parseCategoryEnum(json['category']),
      ratingEnum: _parseRatingEnum(json['rating']),
    );
  }

  static List<int> _parseIdList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is int || (item is Map && item['id'] is int))
          .map((item) => item is int ? item : item['id'] as int)
          .toList();
    }
    return [];
  }

  static AgeRatingCategoryEnum? _parseCategoryEnum(dynamic category) {
    if (category is int) {
      return AgeRatingCategoryEnum.fromValue(category);
    }
    return null;
  }

  static AgeRatingRatingEnum? _parseRatingEnum(dynamic rating) {
    if (rating is int) {
      return AgeRatingRatingEnum.fromValue(rating);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'content_descriptions': contentDescriptions,
      'organization': organizationId,
      'rating_category': ratingCategoryId,
      'rating_content_descriptions': ratingContentDescriptions,
      'rating_cover_url': ratingCoverUrl,
      'synopsis': synopsis,
    };
  }
}