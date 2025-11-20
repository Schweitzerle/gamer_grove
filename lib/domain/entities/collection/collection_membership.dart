// lib/domain/entities/collection_membership.dart
import 'package:equatable/equatable.dart';

class CollectionMembership extends Equatable {

  const CollectionMembership({
    required this.id,
    required this.checksum,
    this.collectionId,
    this.gameId,
    this.typeId,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final int? collectionId;
  final int? gameId;
  final int? typeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    checksum,
    collectionId,
    gameId,
    typeId,
    createdAt,
    updatedAt,
  ];
}