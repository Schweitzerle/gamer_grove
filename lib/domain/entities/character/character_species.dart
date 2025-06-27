// lib/domain/entities/character_species.dart
import 'package:equatable/equatable.dart';

class CharacterSpecies extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CharacterSpecies({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, checksum, name, createdAt, updatedAt];
}