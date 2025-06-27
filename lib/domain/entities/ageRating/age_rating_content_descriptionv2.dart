// lib/domain/entities/age_rating_content_description_v2.dart
import 'package:equatable/equatable.dart';

class AgeRatingContentDescriptionV2 extends Equatable {
  final int id;
  final String checksum;
  final DateTime createdAt;
  final String description;
  final int descriptionType; // Reference ID for Age Rating Content Description Type
  final int organization; // Reference ID for Age Rating Organization
  final DateTime updatedAt;

  const AgeRatingContentDescriptionV2({
    required this.id,
    required this.checksum,
    required this.createdAt,
    required this.description,
    required this.descriptionType,
    required this.organization,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
    id,
    checksum,
    createdAt,
    description,
    descriptionType,
    organization,
    updatedAt
  ];
}