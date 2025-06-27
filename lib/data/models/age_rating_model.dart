// ===== ERWEITERTE AGE RATING MODEL =====
// lib/data/models/age_rating_model.dart (ERWEITERT)
import '../../domain/entities/age_rating.dart';

class AgeRatingModel extends AgeRating {
  const AgeRatingModel({
    required super.id,
    required super.organization,
    required super.ratingCategory,
    super.synopsis,
    super.ratingCoverUrl,
    super.contentDescriptions,
  });

  factory AgeRatingModel.fromJson(Map<String, dynamic> json) {
    return AgeRatingModel(
      id: json['id'] ?? 0,
      organization: _parseOrganization(json['organization']),
      ratingCategory: _parseRatingCategory(json['rating_category']),
      synopsis: json['synopsis'],
      ratingCoverUrl: json['rating_cover_url'],
      contentDescriptions: _parseContentDescriptions(json['rating_content_descriptions']),
    );
  }

  static AgeRatingOrganization _parseOrganization(dynamic org) {
    if (org is Map && org['id'] is int) {
      switch (org['id']) {
        case 1: return AgeRatingOrganization.esrb;
        case 2: return AgeRatingOrganization.pegi;
        case 3: return AgeRatingOrganization.cero;
        case 4: return AgeRatingOrganization.usk;
        case 5: return AgeRatingOrganization.grac;
        case 6: return AgeRatingOrganization.classInd;
        case 7: return AgeRatingOrganization.acb;
        default: return AgeRatingOrganization.unknown;
      }
    } else if (org is int) {
      // Fallback für alte Category-Werte
      switch (org) {
        case 1: return AgeRatingOrganization.esrb;
        case 2: return AgeRatingOrganization.pegi;
        case 3: return AgeRatingOrganization.cero;
        case 4: return AgeRatingOrganization.usk;
        case 5: return AgeRatingOrganization.grac;
        case 6: return AgeRatingOrganization.classInd;
        case 7: return AgeRatingOrganization.acb;
        default: return AgeRatingOrganization.unknown;
      }
    }
    return AgeRatingOrganization.unknown;
  }

  static AgeRatingCategory _parseRatingCategory(dynamic rating) {
    if (rating is Map && rating['id'] is int) {
      return _mapRatingCategoryId(rating['id']);
    } else if (rating is int) {
      return _mapRatingCategoryId(rating);
    }
    return AgeRatingCategory.unknown;
  }

  static AgeRatingCategory _mapRatingCategoryId(int id) {
    switch (id) {
      case 1: return AgeRatingCategory.three;
      case 2: return AgeRatingCategory.seven;
      case 3: return AgeRatingCategory.twelve;
      case 4: return AgeRatingCategory.sixteen;
      case 5: return AgeRatingCategory.eighteen;
      case 6: return AgeRatingCategory.rp;
      case 7: return AgeRatingCategory.ec;
      case 8: return AgeRatingCategory.e;
      case 9: return AgeRatingCategory.e10;
      case 10: return AgeRatingCategory.t;
      case 11: return AgeRatingCategory.m;
      case 12: return AgeRatingCategory.ao;
      case 13: return AgeRatingCategory.ceroA;
      case 14: return AgeRatingCategory.ceroB;
      case 15: return AgeRatingCategory.ceroC;
      case 16: return AgeRatingCategory.ceroD;
      case 17: return AgeRatingCategory.ceroZ;
      case 18: return AgeRatingCategory.usk0;
      case 19: return AgeRatingCategory.usk6;
      case 20: return AgeRatingCategory.usk12;
      case 21: return AgeRatingCategory.usk16;
      case 22: return AgeRatingCategory.usk18;
      case 23: return AgeRatingCategory.gracAll;
      case 24: return AgeRatingCategory.gracTwelve;
      case 25: return AgeRatingCategory.gracFifteen;
      case 26: return AgeRatingCategory.gracEighteen;
      case 27: return AgeRatingCategory.gracTesting;
      case 28: return AgeRatingCategory.classIndL;
      case 29: return AgeRatingCategory.classIndTen;
      case 30: return AgeRatingCategory.classIndTwelve;
      case 31: return AgeRatingCategory.classIndFourteen;
      case 32: return AgeRatingCategory.classIndSixteen;
      case 33: return AgeRatingCategory.classIndEighteen;
      case 34: return AgeRatingCategory.acbG;
      case 35: return AgeRatingCategory.acbPG;
      case 36: return AgeRatingCategory.acbM;
      case 37: return AgeRatingCategory.acbMA15;
      case 38: return AgeRatingCategory.acbR18;
      case 39: return AgeRatingCategory.acbRC;
      default: return AgeRatingCategory.unknown;
    }
  }

  static List<String> _parseContentDescriptions(dynamic descriptions) {
    if (descriptions is List) {
      return descriptions
          .where((item) => item is Map && item['description'] is String)
          .map((item) => item['description'] as String)
          .toList();
    }
    return [];
  }
}