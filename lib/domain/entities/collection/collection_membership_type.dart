// lib/domain/entities/collection_membership_type.dart
import 'package:equatable/equatable.dart';

class CollectionMembershipType extends Equatable {

  const CollectionMembershipType({
    required this.id,
    required this.checksum,
    required this.name,
    this.description,
    this.allowedCollectionTypeId,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String name;
  final String? description;
  final int? allowedCollectionTypeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    description,
    allowedCollectionTypeId,
    createdAt,
    updatedAt,
  ];
}