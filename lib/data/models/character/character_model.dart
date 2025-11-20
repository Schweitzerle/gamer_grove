// lib/data/models/character/character_model.dart - UPDATED VERSION
import 'package:gamer_grove/domain/entities/character/character_mug_shot.dart';

import '../../../domain/entities/character/character.dart';
import '../../../domain/entities/character/character_gender.dart';
import '../../../domain/entities/character/character_species.dart';
import '../../../domain/entities/game/game.dart';

class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.akas,
    super.characterGenderId,
    super.characterSpeciesId,
    super.countryName,
    super.description,
    super.gameIds,
    super.mugShot,
    super.slug,
    super.url,
    super.createdAt,
    super.updatedAt,
    super.genderEnum,
    super.speciesEnum,
    super.mugShotImageId, // 🆕 ADD this
    super.games, // 🆕 ADD this
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    // Parse the new character_gender and character_species IDs
    final characterGenderId = json['character_gender'] as int?;
    final characterSpeciesId = json['character_species'] as int?;

    return CharacterModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      akas: _parseStringList(json['akas']),
      characterGenderId: characterGenderId,
      characterSpeciesId: characterSpeciesId,
      countryName: json['country_name'],
      description: json['description'],
      gameIds: _parseIdList(json['games']),
      mugShot: _parseMugShot(json['mug_shot']),
      slug: json['slug'],
      url: json['url'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      // Use character_gender/character_species IDs to determine enum values
      // If they're not available, fall back to deprecated gender/species fields
      genderEnum: characterGenderId != null
          ? _parseGenderEnum(characterGenderId)
          : _parseGenderEnum(json['gender']),
      speciesEnum: characterSpeciesId != null
          ? _parseSpeciesEnum(characterSpeciesId)
          : _parseSpeciesEnum(json['species']),
      // 🆕 NEW: Extract image ID from nested mug_shot object
      mugShotImageId: _extractMugShotImageId(json['mug_shot']),
    );
  }

  // 🆕 NEW: Extract imageId from mug_shot data
  static String? _extractMugShotImageId(dynamic mugShotData) {
    if (mugShotData == null) return null;

    // If mug_shot is an object with image_id
    if (mugShotData is Map<String, dynamic>) {
      return mugShotData['image_id']?.toString();
    }

    // If mug_shot is just an ID (int), we'll need to fetch it separately
    // This will be handled in the repository level
    return null;
  }

  // 🆕 NEW: Factory method when we have separate mugShot data and games
  factory CharacterModel.fromJsonWithMugShot(
    Map<String, dynamic> characterJson,
    Map<String, dynamic>? mugShotJson, {
    List<Game>? games, // 🆕 ADD this parameter
  }) {
    final character = CharacterModel.fromJson(characterJson);

    final mugShotImageId = mugShotJson?['image_id']?.toString();

    return CharacterModel(
      id: character.id,
      checksum: character.checksum,
      name: character.name,
      akas: character.akas,
      characterGenderId: character.characterGenderId,
      characterSpeciesId: character.characterSpeciesId,
      countryName: character.countryName,
      description: character.description,
      gameIds: character.gameIds,
      mugShot: character.mugShot,
      slug: character.slug,
      url: character.url,
      createdAt: character.createdAt,
      updatedAt: character.updatedAt,
      genderEnum: character.genderEnum,
      speciesEnum: character.speciesEnum,
      mugShotImageId: mugShotImageId, // 🆕 Set the actual image ID
      games: games, // 🆕 Set the actual games
    );
  }

  // Existing helper methods (unchanged)
  static List<String> _parseStringList(dynamic data) {
    if (data is List) {
      return data.whereType<String>().map((item) => item.toString()).toList();
    }
    return [];
  }

  static List<int> _parseIdList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is int || (item is Map && item['id'] is int))
          .map((item) => item is int ? item : item['id'] as int)
          .toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  static CharacterGenderEnum? _parseGenderEnum(dynamic gender) {
    if (gender is int) {
      return CharacterGenderEnum.fromValue(gender);
    }
    return null;
  }

  static CharacterSpeciesEnum? _parseSpeciesEnum(dynamic species) {
    if (species is int) {
      return CharacterSpeciesEnum.fromValue(species);
    }
    return null;
  }

  static CharacterMugShot? _parseMugShot(dynamic mugShot) {
    if (mugShot is Map<String, dynamic>) {
      return CharacterMugShot(
        id: mugShot['id'] ?? 0,
        checksum: mugShot['checksum'] ?? '',
        imageId: mugShot['image_id']?.toString() ?? '',
        height: mugShot['height'] ?? 0,
        width: mugShot['width'] ?? 0,
        url: mugShot['url'],
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'name': name,
      'akas': akas,
      'character_gender': characterGenderId,
      'character_species': characterSpeciesId,
      'country_name': countryName,
      'description': description,
      'games': gameIds,
      'mug_shot': mugShot,
      'slug': slug,
      'url': url,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'gender': genderEnum?.value,
      'species': speciesEnum?.value,
      // Note: mugShotImageId is derived, not stored directly in JSON
    };
  }
}
