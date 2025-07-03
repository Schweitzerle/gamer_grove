// lib/domain/entities/character.dart
import 'package:equatable/equatable.dart';

import 'character_gender.dart';
import 'character_species.dart';


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