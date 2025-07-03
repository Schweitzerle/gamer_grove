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

// Character Species Enum (DEPRECATED but still useful)
enum CharacterSpeciesEnum {
  human(1),
  alien(2),
  animal(3),
  android(4),
  unknown(5);

  const CharacterSpeciesEnum(this.value);
  final int value;

  static CharacterSpeciesEnum fromValue(int value) {
    return values.firstWhere(
          (species) => species.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case human: return 'Human';
      case alien: return 'Alien';
      case animal: return 'Animal';
      case android: return 'Android';
      case unknown: return 'Unknown';
    }
  }
}
