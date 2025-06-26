// lib/domain/entities/age_rating.dart
import 'package:equatable/equatable.dart';

enum AgeRatingCategory {
  esrb,
  pegi,
  cero,
  usk,
  oflc,
  unknown,
}

enum AgeRatingRating {
  three,
  seven,
  twelve,
  sixteen,
  eighteen,
  rp,
  ec,
  e,
  e10,
  t,
  m,
  ao,
  unknown,
}

class AgeRating extends Equatable {
  final int id;
  final AgeRatingCategory category;
  final AgeRatingRating rating;
  final String? synopsis;

  const AgeRating({
    required this.id,
    required this.category,
    required this.rating,
    this.synopsis,
  });

  String get displayName {
    switch (category) {
      case AgeRatingCategory.esrb:
        switch (rating) {
          case AgeRatingRating.ec:
            return 'EC';
          case AgeRatingRating.e:
            return 'E';
          case AgeRatingRating.e10:
            return 'E10+';
          case AgeRatingRating.t:
            return 'T';
          case AgeRatingRating.m:
            return 'M';
          case AgeRatingRating.ao:
            return 'AO';
          case AgeRatingRating.rp:
            return 'RP';
          default:
            return 'ESRB';
        }
      case AgeRatingCategory.pegi:
        switch (rating) {
          case AgeRatingRating.three:
            return 'PEGI 3';
          case AgeRatingRating.seven:
            return 'PEGI 7';
          case AgeRatingRating.twelve:
            return 'PEGI 12';
          case AgeRatingRating.sixteen:
            return 'PEGI 16';
          case AgeRatingRating.eighteen:
            return 'PEGI 18';
          default:
            return 'PEGI';
        }
      default:
        return category.toString().toUpperCase();
    }
  }

  @override
  List<Object?> get props => [id, category, rating, synopsis];
}