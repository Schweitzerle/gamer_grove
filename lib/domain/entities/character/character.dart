// lib/domain/entities/character.dart
import 'package:equatable/equatable.dart';

// Character Gender Enum (DEPRECATED but still useful)
enum CharacterGenderEnum {
  male(0),
  female(1),
  other(2),
  unknown(-1);

  const CharacterGenderEnum(this.value);
  final int value;

  static CharacterGenderEnum fromValue(int value) {
    return values.firstWhere(
          (gender) => gender.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case male: return 'Male';
      case female: return 'Female';
      case other: return 'Other';
      case unknown: return 'Unknown';
    }
  }
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

class Character extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final List<String> akas;
  final int? characterGenderId;
  final int? characterSpeciesId;
  final String? countryName;
  final String? description;
  final List<int> gameIds;
  final int? mugShotId;
  final String? slug;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // DEPRECATED fields but still useful for backwards compatibility
  final CharacterGenderEnum? genderEnum;
  final CharacterSpeciesEnum? speciesEnum;

  const Character({
    required this.id,
    required this.checksum,
    required this.name,
    this.akas = const [],
    this.characterGenderId,
    this.characterSpeciesId,
    this.countryName,
    this.description,
    this.gameIds = const [],
    this.mugShotId,
    this.slug,
    this.url,
    this.createdAt,
    this.updatedAt,
    this.genderEnum,
    this.speciesEnum,
  });

  // Helper getters
  String get displayGender {
    if (genderEnum != null) {
      return genderEnum!.displayName;
    }
    return 'Unknown';
  }

  String get displaySpecies {
    if (speciesEnum != null) {
      return speciesEnum!.displayName;
    }
    return 'Unknown';
  }

  bool get hasGames => gameIds.isNotEmpty;
  bool get hasMugShot => mugShotId != null;
  bool get hasDescription => description != null && description!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    akas,
    characterGenderId,
    characterSpeciesId,
    countryName,
    description,
    gameIds,
    mugShotId,
    slug,
    url,
    createdAt,
    updatedAt,
    genderEnum,
    speciesEnum,
  ];
}