// lib/domain/entities/collection_type.dart
import 'package:equatable/equatable.dart';

class CollectionType extends Equatable {

  const CollectionType({
    required this.id,
    required this.checksum,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, checksum, name, description, createdAt, updatedAt];
}