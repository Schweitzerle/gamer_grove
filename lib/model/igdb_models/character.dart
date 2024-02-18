import 'package:gamer_grove/model/igdb_models/character_mugshot.dart';

import 'game.dart';

class Character {
  int id;
  List<String>? akas;
  String? checksum;
  String? countryName;
  int? createdAt;
  String? description;
  List<Game>? gameIDs;
  String? gender;
  CharacterMugshot? mugShotID;
  String? name;
  String? slug;
  String? species;
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
          ? List<Game>.from(
        json['games'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      gender: json['gender'] != null
          ? _genderToString(
          GenderEnumExtension.fromValue(json['gender']))
          : null,
      mugShotID: json['mug_shot'] != null
          ? (json['mug_shot'] is int
          ? CharacterMugshot(id: json['mug_shot'])
          : CharacterMugshot.fromJson(json['mug_shot']))
          : null,

      name: json['name'],
      slug: json['slug'],
      species: json['species'] != null
          ? _speciesToString(
          SpeciesEnumExtension.fromValue(json['species']))
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
  String get value {
    return _genderToString(this);
  }

  static GenderEnum fromValue(int value) {
    return GenderEnum.values[value];
  }
}

String _genderToString(GenderEnum? gender) {
  if (gender == null) return 'N/A';
  switch (gender) {
    case GenderEnum.Female:
      return 'Female';
    case GenderEnum.Male:
      return 'Male';
    case GenderEnum.Other:
      return 'Other';
    default:
      return 'N/A';
  }
}


extension SpeciesEnumExtension on SpeciesEnum {
  String get value {
    return _speciesToString(this);
  }

  static SpeciesEnum fromValue(int value) {
    return SpeciesEnum.values[value - 1];
  }
}


String _speciesToString(SpeciesEnum? gender) {
  if (gender == null) return 'N/A';
  switch (gender) {
    case SpeciesEnum.Alien:
      return 'Alien';
    case SpeciesEnum.Android:
      return 'Android';
    case SpeciesEnum.Animal:
      return 'Animal';
    case SpeciesEnum.Human:
      return 'Human';
    case SpeciesEnum.Unknown:
      return 'Unknown';
    default:
      return 'N/A';
  }
}