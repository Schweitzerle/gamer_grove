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

// ==========================================

// lib/domain/entities/character/character_species.dart
enum CharacterSpecies {
  human(1, 'Human'),
  alien(2, 'Alien'),
  animal(3, 'Animal'),
  android(4, 'Android'),
  unknown(5, 'Unknown');

  const CharacterSpecies(this.value, this.displayName);
  final int value;
  final String displayName;

  static CharacterSpecies fromValue(int value) {
    return values.firstWhere(
          (species) => species.value == value,
      orElse: () => unknown,
    );
  }
}
