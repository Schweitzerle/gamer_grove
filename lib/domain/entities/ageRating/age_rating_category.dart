// lib/domain/entities/age_rating_category.dart
import 'package:equatable/equatable.dart';

class AgeRatingCategory extends Equatable {
  final int id;
  final String checksum;
  final DateTime? createdAt;
  final int? organizationId;
  final String rating;
  final DateTime? updatedAt;

  const AgeRatingCategory({
    required this.id,
    required this.checksum,
    required this.rating,
    this.organizationId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, checksum, rating, organizationId, createdAt, updatedAt];
}