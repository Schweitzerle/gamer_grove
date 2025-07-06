// ===== UPDATED AGE RATING MODEL =====
// lib/data/models/ageRating/age_rating_model.dart
import '../../../domain/entities/ageRating/age_rating.dart';
import '../../../domain/entities/ageRating/age_rating_organization.dart';
import 'age_rating_category_model.dart';
import 'age_rating_organization.dart';

class AgeRatingModel extends AgeRating {
  const AgeRatingModel({
    required super.id,
    required super.checksum,
    super.contentDescriptions,
    super.organizationId,
    super.organization, // NEU
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
      organizationId: _parseOrganizationId(json['organization']),
      organization: _parseOrganization(json['organization']), // NEU
      ratingCategoryId: json['rating_category'],
      ratingContentDescriptions: _parseIdList(json['rating_content_descriptions']),
      ratingCoverUrl: json['rating_cover_url'],
      synopsis: json['synopsis'],
      categoryEnum: _parseCategory(json['category']),
      ratingEnum: _parseRating(json['rating']),
    );
  }

  // NEU: Parse organization data
  static int? _parseOrganizationId(dynamic orgData) {
    if (orgData is int) {
      return orgData;
    } else if (orgData is Map<String, dynamic>) {
      return orgData['id'];
    }
    return null;
  }

  // NEU: Parse organization object
  static AgeRatingOrganization? _parseOrganization(dynamic orgData) {
    if (orgData is Map<String, dynamic>) {
      try {
        return AgeRatingOrganizationModel.fromJson(orgData);
      } catch (e) {
        print('Error parsing age rating organization: $e');
        return null;
      }
    }
    return null;
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

  static AgeRatingCategoryEnum? _parseCategory(dynamic category) {
    if (category is int) {
      return AgeRatingCategoryEnum.fromValue(category);
    }
    return null;
  }

  static AgeRatingRatingEnum? _parseRating(dynamic rating) {
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
      'category': categoryEnum?.value,
      'rating': ratingEnum?.value,
    };
  }
}

