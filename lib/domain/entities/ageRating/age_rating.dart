// ===== UPDATED AGE RATING ENTITY =====
// lib/domain/entities/ageRating/age_rating.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/ageRating/age_rating_category.dart';
import 'age_rating_organization.dart'; // Import für AgeRatingOrganization

// Age Rating Category Enum (DEPRECATED but still used)
enum AgeRatingCategoryEnum {
  esrb(1),
  pegi(2),
  cero(3),
  usk(4),
  grac(5),
  classInd(6),
  acb(7),
  unknown(0);

  const AgeRatingCategoryEnum(this.value);
  final int value;

  static AgeRatingCategoryEnum fromValue(int value) {
    return values.firstWhere(
      (category) => category.value == value,
      orElse: () => unknown,
    );
  }
}

// Age Rating Enum (DEPRECATED but still used)
enum AgeRatingRatingEnum {
  three(1),
  seven(2),
  twelve(3),
  sixteen(4),
  eighteen(5),
  rp(6),
  ec(7),
  e(8),
  e10(9),
  t(10),
  m(11),
  ao(12),
  ceroA(13),
  ceroB(14),
  ceroC(15),
  ceroD(16),
  ceroZ(17),
  usk0(18),
  usk6(19),
  usk12(20),
  usk16(21),
  usk18(22),
  gracAll(23),
  gracTwelve(24),
  gracFifteen(25),
  gracEighteen(26),
  gracTesting(27),
  classIndL(28),
  classIndTen(29),
  classIndTwelve(30),
  classIndFourteen(31),
  classIndSixteen(32),
  classIndEighteen(33),
  acbG(34),
  acbPg(35),
  acbM(36),
  acbMa15(37),
  acbR18(38),
  acbRc(39),
  unknown(0);

  const AgeRatingRatingEnum(this.value);
  final int value;

  static AgeRatingRatingEnum fromValue(int value) {
    return values.firstWhere(
      (rating) => rating.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case ec:
        return 'EC';
      case e:
        return 'E';
      case e10:
        return 'E10+';
      case t:
        return 'T';
      case m:
        return 'M';
      case ao:
        return 'AO';
      case rp:
        return 'RP';
      case three:
        return 'PEGI 3';
      case seven:
        return 'PEGI 7';
      case twelve:
        return 'PEGI 12';
      case sixteen:
        return 'PEGI 16';
      case eighteen:
        return 'PEGI 18';
      case usk0:
        return 'USK 0';
      case usk6:
        return 'USK 6';
      case usk12:
        return 'USK 12';
      case usk16:
        return 'USK 16';
      case usk18:
        return 'USK 18';
      case ceroA:
        return 'CERO A';
      case ceroB:
        return 'CERO B';
      case ceroC:
        return 'CERO C';
      case ceroD:
        return 'CERO D';
      case ceroZ:
        return 'CERO Z';
      case acbG:
        return 'G';
      case acbPg:
        return 'PG';
      case acbM:
        return 'M';
      case acbMa15:
        return 'MA15+';
      case acbR18:
        return 'R18+';
      case acbRc:
        return 'RC';
      default:
        return name.toUpperCase();
    }
  }
}

class AgeRating extends Equatable {
  final int id;
  final String checksum;
  final List<int> contentDescriptions;
  final int? organizationId;
  final AgeRatingOrganization?
      organization; // NEU: Direktes Organization Objekt
  final AgeRatingCategory? ratingCategory;
  final String?
      ratingString; // NEU: Rating string from rating_category (e.g., "PEGI 18", "Mature 17+")
  final List<int> ratingContentDescriptions;
  final String? ratingCoverUrl;
  final String? synopsis;

  // DEPRECATED fields but still useful
  final AgeRatingCategoryEnum? categoryEnum;
  final AgeRatingRatingEnum? ratingEnum;

  const AgeRating({
    required this.id,
    required this.checksum,
    this.contentDescriptions = const [],
    this.organizationId,
    this.organization, // NEU
    this.ratingCategory,
    this.ratingString, // NEU
    this.ratingContentDescriptions = const [],
    this.ratingCoverUrl,
    this.synopsis,
    this.categoryEnum,
    this.ratingEnum,
  });

  String get displayName {
    // Priority 1: Use ratingString if available
    if (ratingString != null && ratingString!.isNotEmpty) {
      return ratingString!;
    }

    // Priority 2: Use ratingEnum if available
    if (ratingEnum != null && ratingEnum != AgeRatingRatingEnum.unknown) {
      return ratingEnum!.displayName;
    }

    // Priority 3: Use ratingCategoryId as fallback
    if (ratingCategory != null) {
      return 'Rating ID: $ratingCategory';
    }

    // Last resort
    return 'Unknown Rating';
  }

  // NEU: Helper getters für Rating-Organisationen
  bool get isESRB =>
      organization?.isESRB ?? (categoryEnum == AgeRatingCategoryEnum.esrb);
  bool get isPEGI =>
      organization?.isPEGI ?? (categoryEnum == AgeRatingCategoryEnum.pegi);
  bool get isUSK =>
      organization?.isUSK ?? (categoryEnum == AgeRatingCategoryEnum.usk);
  bool get isCERO =>
      organization?.isCERO ?? (categoryEnum == AgeRatingCategoryEnum.cero);
  bool get isGRAC =>
      organization?.isGRAC ?? (categoryEnum == AgeRatingCategoryEnum.grac);
  bool get isClassInd =>
      organization?.isClassInd ??
      (categoryEnum == AgeRatingCategoryEnum.classInd);
  bool get isACB =>
      organization?.isACB ?? (categoryEnum == AgeRatingCategoryEnum.acb);

  String get organizationName {
    // Priority 1: Use organization name if available
    if (organization != null && organization!.name.isNotEmpty) {
      return organization!.name;
    }

    // Priority 2: Use categoryEnum if available
    if (categoryEnum != null && categoryEnum != AgeRatingCategoryEnum.unknown) {
      return categoryEnum!.name.toUpperCase();
    }

    // Priority 3: Use organizationId as fallback
    if (organizationId != null) {
      // Map known organization IDs to names
      switch (organizationId) {
        case 1:
          return 'ESRB';
        case 2:
          return 'PEGI';
        case 3:
          return 'CERO';
        case 4:
          return 'USK';
        case 5:
          return 'GRAC';
        case 6:
          return 'ClassInd';
        case 7:
          return 'ACB';
        default:
          return 'Org ID: $organizationId';
      }
    }

    return 'Unknown';
  }

  @override
  List<Object?> get props => [
        id,
        checksum,
        contentDescriptions,
        organizationId,
        organization, // NEU
        ratingCategory,
        ratingString, // NEU
        ratingContentDescriptions,
        ratingCoverUrl,
        synopsis,
        categoryEnum,
        ratingEnum,
      ];
}
