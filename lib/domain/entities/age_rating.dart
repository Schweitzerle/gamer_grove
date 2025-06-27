// ===== ERWEITERTE AGE RATING ENTITY =====
// lib/domain/entities/age_rating.dart (ERWEITERT)
import 'package:equatable/equatable.dart';

enum AgeRatingOrganization {
  esrb,        // Entertainment Software Rating Board
  pegi,        // Pan European Game Information
  cero,        // Computer Entertainment Rating Organization
  usk,         // Unterhaltungssoftware Selbstkontrolle
  grac,        // Game Rating and Administration Committee
  classInd,    // Classificação Indicativa
  acb,         // Australian Classification Board
  unknown,
}

enum AgeRatingCategory {
  three,
  seven,
  twelve,
  sixteen,
  eighteen,
  rp,          // Rating Pending
  ec,          // Early Childhood
  e,           // Everyone
  e10,         // Everyone 10+
  t,           // Teen
  m,           // Mature
  ao,          // Adults Only
  ceroA,       // CERO A (All ages)
  ceroB,       // CERO B (Ages 12 and up)
  ceroC,       // CERO C (Ages 15 and up)
  ceroD,       // CERO D (Ages 17 and up)
  ceroZ,       // CERO Z (Ages 18 and up only)
  usk0,        // USK 0
  usk6,        // USK 6
  usk12,       // USK 12
  usk16,       // USK 16
  usk18,       // USK 18
  gracAll,     // GRAC All
  gracTwelve,  // GRAC 12
  gracFifteen, // GRAC 15
  gracEighteen,// GRAC 18
  gracTesting, // GRAC Testing
  classIndL,   // CLASS_IND L
  classIndTen, // CLASS_IND 10
  classIndTwelve, // CLASS_IND 12
  classIndFourteen, // CLASS_IND 14
  classIndSixteen, // CLASS_IND 16
  classIndEighteen, // CLASS_IND 18
  acbG,        // ACB G (General)
  acbPG,       // ACB PG (Parental Guidance)
  acbM,        // ACB M (Mature)
  acbMA15,     // ACB MA15+ (Mature Accompanied)
  acbR18,      // ACB R18+ (Restricted)
  acbRC,       // ACB RC (Refused Classification)
  unknown,
}

class AgeRating extends Equatable {
  final int id;
  final AgeRatingOrganization organization;
  final AgeRatingCategory ratingCategory;
  final String? synopsis;
  final String? ratingCoverUrl;
  final List<String> contentDescriptions;

  const AgeRating({
    required this.id,
    required this.organization,
    required this.ratingCategory,
    this.synopsis,
    this.ratingCoverUrl,
    this.contentDescriptions = const [],
  });

  String get displayName {
    switch (organization) {
      case AgeRatingOrganization.esrb:
        switch (ratingCategory) {
          case AgeRatingCategory.ec: return 'EC';
          case AgeRatingCategory.e: return 'E';
          case AgeRatingCategory.e10: return 'E10+';
          case AgeRatingCategory.t: return 'T';
          case AgeRatingCategory.m: return 'M';
          case AgeRatingCategory.ao: return 'AO';
          case AgeRatingCategory.rp: return 'RP';
          default: return 'ESRB';
        }
      case AgeRatingOrganization.pegi:
        switch (ratingCategory) {
          case AgeRatingCategory.three: return 'PEGI 3';
          case AgeRatingCategory.seven: return 'PEGI 7';
          case AgeRatingCategory.twelve: return 'PEGI 12';
          case AgeRatingCategory.sixteen: return 'PEGI 16';
          case AgeRatingCategory.eighteen: return 'PEGI 18';
          default: return 'PEGI';
        }
      case AgeRatingOrganization.cero:
        switch (ratingCategory) {
          case AgeRatingCategory.ceroA: return 'CERO A';
          case AgeRatingCategory.ceroB: return 'CERO B';
          case AgeRatingCategory.ceroC: return 'CERO C';
          case AgeRatingCategory.ceroD: return 'CERO D';
          case AgeRatingCategory.ceroZ: return 'CERO Z';
          default: return 'CERO';
        }
      case AgeRatingOrganization.usk:
        switch (ratingCategory) {
          case AgeRatingCategory.usk0: return 'USK 0';
          case AgeRatingCategory.usk6: return 'USK 6';
          case AgeRatingCategory.usk12: return 'USK 12';
          case AgeRatingCategory.usk16: return 'USK 16';
          case AgeRatingCategory.usk18: return 'USK 18';
          default: return 'USK';
        }
      case AgeRatingOrganization.grac:
        switch (ratingCategory) {
          case AgeRatingCategory.gracAll: return 'GRAC All';
          case AgeRatingCategory.gracTwelve: return 'GRAC 12';
          case AgeRatingCategory.gracFifteen: return 'GRAC 15';
          case AgeRatingCategory.gracEighteen: return 'GRAC 18';
          default: return 'GRAC';
        }
      case AgeRatingOrganization.acb:
        switch (ratingCategory) {
          case AgeRatingCategory.acbG: return 'G';
          case AgeRatingCategory.acbPG: return 'PG';
          case AgeRatingCategory.acbM: return 'M';
          case AgeRatingCategory.acbMA15: return 'MA15+';
          case AgeRatingCategory.acbR18: return 'R18+';
          case AgeRatingCategory.acbRC: return 'RC';
          default: return 'ACB';
        }
      default:
        return organization.toString().toUpperCase();
    }
  }

  @override
  List<Object?> get props => [
    id, organization, ratingCategory, synopsis,
    ratingCoverUrl, contentDescriptions
  ];
}
