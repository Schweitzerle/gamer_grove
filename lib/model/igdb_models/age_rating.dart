import 'package:gamer_grove/model/igdb_models/age_rating_description.dart';

class AgeRating {
  int id;
  AgeRatingCategory? category;
  String? checksum;
  List<int>? contentDescriptions;
  AgeRatingRating? rating;
  String? ratingCoverUrl;
  String? synopsis;

  AgeRating({
    required this.id,
    this.category,
    this.checksum,
    this.contentDescriptions,
    this.rating,
    this.ratingCoverUrl,
    this.synopsis,
  });

  factory AgeRating.fromJson(Map<String, dynamic> json) {
    return AgeRating(
      id: json['id'],
      category: json['category'] != null
          ? AgeRatingCategoryExtension.fromValue(json['category'])
          : null,
      checksum: json['checksum'],
      contentDescriptions: json['content_descriptions'] != null
          ? List<int>.from(json['content_descriptions'])
          : null,
      rating: json['rating'] != null
          ? AgeRatingRatingExtension.fromString(json['rating'])
          : null,
      ratingCoverUrl: json['rating_cover_url'],
      synopsis: json['synopsis'],
    );
  }

}

enum AgeRatingCategory {
  ESRB,
  PEGI,
  CERO,
  USK,
  GRAC,
  CLASS_IND,
  ACB,
}

extension AgeRatingCategoryExtension on AgeRatingCategory {
  int get value {
    return this.index + 1;
  }

  static AgeRatingCategory fromValue(int value) {
    return AgeRatingCategory.values[value - 1];
  }
}

enum AgeRatingRating {
  Three,
  Seven,
  Twelve,
  Sixteen,
  Eighteen,
  RP,
  EC,
  E,
  E10,
  T,
  M,
  AO,
  CERO_A,
  CERO_B,
  CERO_C,
  CERO_D,
  CERO_Z,
  USK_0,
  USK_6,
  USK_12,
  USK_16,
  USK_18,
  GRAC_ALL,
  GRAC_Twelve,
  GRAC_Fifteen,
  GRAC_Eighteen,
  GRAC_TESTING,
  CLASS_IND_L,
  CLASS_IND_Ten,
  CLASS_IND_Twelve,
  CLASS_IND_Fourteen,
  CLASS_IND_Sixteen,
  CLASS_IND_Eighteen,
  ACB_G,
  ACB_PG,
  ACB_M,
  ACB_MA15,
  ACB_R18,
  ACB_RC,
}

extension AgeRatingRatingExtension on AgeRatingRating {
  int get value {
    return this.index + 1;
  }

  static AgeRatingRating fromString(int value) {
    return AgeRatingRating.values[value - 1];
  }
}
