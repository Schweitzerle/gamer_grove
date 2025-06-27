// lib/domain/entities/age_rating_organization.dart
import 'package:equatable/equatable.dart';

class AgeRatingOrganization extends Equatable {
  final int id;
  final String checksum;
  final DateTime? createdAt;
  final String name;
  final DateTime? updatedAt;

  const AgeRatingOrganization({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, checksum, name, createdAt, updatedAt];
}