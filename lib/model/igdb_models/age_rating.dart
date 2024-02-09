import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/age_rating_description.dart';

class AgeRating {
  int id;
  String? category; // Changed to String
  String? rating;   // Changed to String
  String? checksum;
  List<int>? contentDescriptions;
  String? ratingCoverUrl;
  String? synopsis;

  AgeRating({
    required this.id,
    this.category,
    this.rating,
    this.checksum,
    this.contentDescriptions,
    this.ratingCoverUrl,
    this.synopsis,
  });

  factory AgeRating.fromJson(Map<String, dynamic> json) {
    return AgeRating(
      id: json['id'],
      category: json['category'] != null
          ? _categoryToString(AgeRatingCategoryExtension.fromValue(json['category']))
          : null,
      rating: json['rating'] != null
          ? _ratingToString(AgeRatingRatingExtension.fromString(json['rating']))
          : null,
      checksum: json['checksum'],
      contentDescriptions: json['content_descriptions'] != null
          ? List<int>.from(json['content_descriptions'])
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
  String get value { // Changed to String
    return _categoryToString(this);
  }

  static AgeRatingCategory fromValue(int value) { // Changed to String
    switch (value) {
      case 1:
        return AgeRatingCategory.ESRB;
      case 2:
        return AgeRatingCategory.PEGI;
      case 3:
        return AgeRatingCategory.CERO;
      case 4:
        return AgeRatingCategory.USK;
      case 5:
        return AgeRatingCategory.GRAC;
      case 6:
        return AgeRatingCategory.CLASS_IND;
      case 7:
        return AgeRatingCategory.ACB;
      default:
        throw ArgumentError('Invalid value');
    }
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
  String get value {
    // Changed to String
    return _ratingToString(this);
  }

  static AgeRatingRating fromString(int value) {
    // Changed parameter type to int
    switch (value) {
      case 1:
        return AgeRatingRating.Three;
      case 2:
        return AgeRatingRating.Seven;
      case 3:
        return AgeRatingRating.Twelve;
      case 4:
        return AgeRatingRating.Sixteen;
      case 5:
        return AgeRatingRating.Eighteen;
      case 6:
        return AgeRatingRating.RP;
      case 7:
        return AgeRatingRating.EC;
      case 8:
        return AgeRatingRating.E;
      case 9:
        return AgeRatingRating.E10;
      case 10:
        return AgeRatingRating.T;
      case 11:
        return AgeRatingRating.M;
      case 12:
        return AgeRatingRating.AO;
      case 13:
        return AgeRatingRating.CERO_A;
      case 14:
        return AgeRatingRating.CERO_B;
      case 15:
        return AgeRatingRating.CERO_C;
      case 16:
        return AgeRatingRating.CERO_D;
      case 17:
        return AgeRatingRating.CERO_Z;
      case 18:
        return AgeRatingRating.USK_0;
      case 19:
        return AgeRatingRating.USK_6;
      case 20:
        return AgeRatingRating.USK_12;
      case 21:
        return AgeRatingRating.USK_16;
      case 22:
        return AgeRatingRating.USK_18;
      case 23:
        return AgeRatingRating.GRAC_ALL;
      case 24:
        return AgeRatingRating.GRAC_Twelve;
      case 25:
        return AgeRatingRating.GRAC_Fifteen;
      case 26:
        return AgeRatingRating.GRAC_Eighteen;
      case 27:
        return AgeRatingRating.GRAC_TESTING;
      case 28:
        return AgeRatingRating.CLASS_IND_L;
      case 29:
        return AgeRatingRating.CLASS_IND_Ten;
      case 30:
        return AgeRatingRating.CLASS_IND_Twelve;
      case 31:
        return AgeRatingRating.CLASS_IND_Fourteen;
      case 32:
        return AgeRatingRating.CLASS_IND_Sixteen;
      case 33:
        return AgeRatingRating.CLASS_IND_Eighteen;
      case 34:
        return AgeRatingRating.ACB_G;
      case 35:
        return AgeRatingRating.ACB_PG;
      case 36:
        return AgeRatingRating.ACB_M;
      case 37:
        return AgeRatingRating.ACB_MA15;
      case 38:
        return AgeRatingRating.ACB_R18;
      case 39:
        return AgeRatingRating.ACB_RC;
      default:
        throw ArgumentError('Invalid value');
    }
  }
}

  String _categoryToString(AgeRatingCategory? category) {
  if (category == null) return 'N/A';
  switch (category) {
    case AgeRatingCategory.ESRB:
      return 'ESRB';
    case AgeRatingCategory.PEGI:
      return 'PEGI';
    case AgeRatingCategory.USK:
      return 'USK';
    default:
      return 'N/A';
  }
}

String _ratingToString(AgeRatingRating? rating) {
  if (rating == null) return 'N/A';
  switch (rating) {
    case AgeRatingRating.Three:
      return 'Three';
    case AgeRatingRating.Seven:
      return 'Seven';
    case AgeRatingRating.Twelve:
      return 'Twelve';
    case AgeRatingRating.Sixteen:
      return 'Sixteen';
    case AgeRatingRating.Eighteen:
      return 'Eighteen';
    case AgeRatingRating.RP:
      return 'RP';
    case AgeRatingRating.EC:
      return 'EC';
    case AgeRatingRating.E:
      return 'E';
    case AgeRatingRating.E10:
      return 'E10';
    case AgeRatingRating.T:
      return 'T';
    case AgeRatingRating.M:
      return 'M';
    case AgeRatingRating.AO:
      return 'AO';
    case AgeRatingRating.CERO_A:
      return 'A';
    case AgeRatingRating.CERO_B:
      return 'B';
    case AgeRatingRating.CERO_C:
      return 'C';
    case AgeRatingRating.CERO_D:
      return 'D';
    case AgeRatingRating.CERO_Z:
      return 'Z';
    case AgeRatingRating.USK_0:
      return '0';
    case AgeRatingRating.USK_6:
      return '6';
    case AgeRatingRating.USK_12:
      return '12';
    case AgeRatingRating.USK_16:
      return '16';
    case AgeRatingRating.USK_18:
      return '18';
    case AgeRatingRating.GRAC_ALL:
      return 'ALL';
    case AgeRatingRating.GRAC_Twelve:
      return 'Twelve';
    case AgeRatingRating.GRAC_Fifteen:
      return 'Fifteen';
    case AgeRatingRating.GRAC_Eighteen:
      return 'ighteen';
    case AgeRatingRating.GRAC_TESTING:
      return 'TESTING';
    case AgeRatingRating.CLASS_IND_L:
      return 'L';
    case AgeRatingRating.CLASS_IND_Ten:
      return 'Ten';
    case AgeRatingRating.CLASS_IND_Twelve:
      return 'Twelve';
    case AgeRatingRating.CLASS_IND_Fourteen:
      return 'Fourteen';
    case AgeRatingRating.CLASS_IND_Sixteen:
      return 'Sixteen';
    case AgeRatingRating.CLASS_IND_Eighteen:
      return 'Eighteen';
    case AgeRatingRating.ACB_G:
      return 'G';
    case AgeRatingRating.ACB_PG:
      return 'PG';
    case AgeRatingRating.ACB_M:
      return 'M';
    case AgeRatingRating.ACB_MA15:
      return 'MA15';
    case AgeRatingRating.ACB_R18:
      return 'R18';
    case AgeRatingRating.ACB_RC:
      return 'RC';
    default:
      return 'N/A';
  }
}
