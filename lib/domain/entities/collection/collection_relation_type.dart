// lib/domain/entities/collection_relation_type.dart
import 'package:equatable/equatable.dart';

class CollectionRelationType extends Equatable {

  const CollectionRelationType({
    required this.id,
    required this.checksum,
    required this.name,
    this.description,
    this.allowedChildTypeId,
    this.allowedParentTypeId,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String name;
  final String? description;
  final int? allowedChildTypeId;
  final int? allowedParentTypeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    description,
    allowedChildTypeId,
    allowedParentTypeId,
    createdAt,
    updatedAt,
  ];
}