// lib/domain/entities/age_rating_category.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/ageRating/age_rating_organization.dart';

class AgeRatingCategory extends Equatable {
  final int id;
  final String checksum;
  final DateTime? createdAt;
  final AgeRatingOrganization? organization;
  final String rating;
  final DateTime? updatedAt;

  const AgeRatingCategory({
    required this.id,
    required this.checksum,
    required this.rating,
    this.organization,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, checksum, rating, organization, createdAt, updatedAt];
}
