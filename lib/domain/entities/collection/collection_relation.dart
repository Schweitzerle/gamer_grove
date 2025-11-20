// lib/domain/entities/collection_relation.dart
import 'package:equatable/equatable.dart';

class CollectionRelation extends Equatable {

  const CollectionRelation({
    required this.id,
    required this.checksum,
    this.childCollectionId,
    this.parentCollectionId,
    this.typeId,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final int? childCollectionId;
  final int? parentCollectionId;
  final int? typeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasParentChild => childCollectionId != null && parentCollectionId != null;

  @override
  List<Object?> get props => [
    id,
    checksum,
    childCollectionId,
    parentCollectionId,
    typeId,
    createdAt,
    updatedAt,
  ];
}