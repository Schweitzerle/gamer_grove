// lib/data/models/age_rating_model.dart
import '../../domain/entities/age_rating.dart';

class AgeRatingModel extends AgeRating {
  const AgeRatingModel({
    required super.id,
    required super.category,
    required super.rating,
    super.synopsis,
  });

  factory AgeRatingModel.fromJson(Map<String, dynamic> json) {
    return AgeRatingModel(
      id: json['id'] ?? 0,
      category: _parseCategory(json['category']),
      rating: _parseRating(json['rating']),
      synopsis: json['synopsis'],
    );
  }

  static AgeRatingCategory _parseCategory(dynamic category) {
    if (category is int) {
      switch (category) {
        case 1: return AgeRatingCategory.esrb;
        case 2: return AgeRatingCategory.pegi;
        case 3: return AgeRatingCategory.cero;
        case 4: return AgeRatingCategory.usk;
        case 5: return AgeRatingCategory.oflc;
        default: return AgeRatingCategory.unknown;
      }
    }
    return AgeRatingCategory.unknown;
  }

  static AgeRatingRating _parseRating(dynamic rating) {
    if (rating is int) {
      switch (rating) {
        case 1: return AgeRatingRating.three;
        case 2: return AgeRatingRating.seven;
        case 3: return AgeRatingRating.twelve;
        case 4: return AgeRatingRating.sixteen;
        case 5: return AgeRatingRating.eighteen;
        case 6: return AgeRatingRating.rp;
        case 7: return AgeRatingRating.ec;
        case 8: return AgeRatingRating.e;
        case 9: return AgeRatingRating.e10;
        case 10: return AgeRatingRating.t;
        case 11: return AgeRatingRating.m;
        case 12: return AgeRatingRating.ao;
        default: return AgeRatingRating.unknown;
      }
    }
    return AgeRatingRating.unknown;
  }
}