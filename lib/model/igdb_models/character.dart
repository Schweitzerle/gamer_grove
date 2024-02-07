import 'package:gamer_grove/model/igdb_models/character_mugshot.dart';

class Character {
  int id;
  List<String>? akas;
  String? checksum;
  String? countryName;
  int? createdAt;
  String? description;
  List<int>? gameIDs;
  GenderEnum? gender;
  CharacterMugshot? mugShotID;
  String? name;
  String? slug;
  SpeciesEnum? species;
  int? updatedAt;
  String? url;

  Character({
    required this.id,
    this.akas,
    this.checksum,
    this.countryName,
    this.createdAt,
    this.description,
    this.gameIDs,
    this.gender,
    this.mugShotID,
    this.name,
    this.slug,
    this.species,
    this.updatedAt,
    this.url,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      akas: json['akas'] != null
          ? List<String>.from(json['akas'])
          : null,
      checksum: json['checksum'],
      countryName: json['country_name'],
      createdAt: json['created_at'],
      description: json['description'],
      gameIDs: json['games'] != null
          ? List<int>.from(json['games'])
          : null,
      gender: json['gender'] != null
          ? GenderEnumExtension.fromValue(json['gender'])
          : null,
      mugShotID: json['mug_shot'] != null
          ? (json['mug_shot'] is int
          ? CharacterMugshot(id: json['mug_shot'])
          : CharacterMugshot.fromJson(json['mug_shot']))
          : null,

      name: json['name'],
      slug: json['slug'],
      species: json['species'] != null
          ? SpeciesEnumExtension.fromValue(json['species'])
          : null,
      updatedAt: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }

}

enum GenderEnum {
  Male,
  Female,
  Other,
}

enum SpeciesEnum {
  Human,
  Alien,
  Animal,
  Android,
  Unknown,
}

extension GenderEnumExtension on GenderEnum {
  int get value {
    return this.index;
  }

  static GenderEnum fromValue(int value) {
    return GenderEnum.values[value];
  }
}

extension SpeciesEnumExtension on SpeciesEnum {
  int get value {
    return this.index + 1;
  }

  static SpeciesEnum fromValue(int value) {
    return SpeciesEnum.values[value - 1];
  }
}
