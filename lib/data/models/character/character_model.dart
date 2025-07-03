// lib/data/models/character_model.dart
import '../../../domain/entities/character/character.dart';
import '../../../domain/entities/character/character_species.dart';

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
    super.mugShotId,
    super.slug,
    super.url,
    super.createdAt,
    super.updatedAt,
    super.genderEnum,
    super.speciesEnum,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      akas: _parseStringList(json['akas']),
      characterGenderId: json['character_gender'],
      characterSpeciesId: json['character_species'],
      countryName: json['country_name'],
      description: json['description'],
      gameIds: _parseIdList(json['games']),
      mugShotId: json['mug_shot'],
      slug: json['slug'],
      url: json['url'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      genderEnum: _parseGenderEnum(json['gender']),
      speciesEnum: _parseSpeciesEnum(json['species']),
    );
  }

  static List<String> _parseStringList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is String)
          .map((item) => item.toString())
          .toList();
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
      'mug_shot': mugShotId,
      'slug': slug,
      'url': url,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'gender': genderEnum?.value,
      'species': speciesEnum?.value,
    };
  }
}