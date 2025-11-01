// lib/domain/entities/character/character.dart - UPDATED VERSION
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/character/character_mug_shot.dart';
import '../game/game.dart';
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
  final CharacterMugShot? mugShot;
  final String? slug;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // DEPRECATED fields but still useful for backwards compatibility
  final CharacterGenderEnum? genderEnum;
  final CharacterSpeciesEnum? speciesEnum;

  // 🆕 NEW: Image URL support (populated when mugShot data is fetched)
  final String? mugShotImageId; // The actual image ID for URL construction

  // 🆕 NEW: Games property (populated when fetched for UI, similar to Game.similarGames)
  final List<Game>? games; // The actual Game objects this character appears in

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
    this.mugShot,
    this.slug,
    this.url,
    this.createdAt,
    this.updatedAt,
    this.genderEnum,
    this.speciesEnum,
    this.mugShotImageId, // 🆕 ADD this
    this.games, // 🆕 ADD this - actual Game objects
  });

  // 🆕 NEW: Helper getters for image URLs (similar to Cover, Screenshot entities)
  String? get imageUrl => mugShotImageId != null ? thumbUrl : null;
  String? get thumbUrl => mugShotImageId != null
      ? 'https://images.igdb.com/igdb/image/upload/t_thumb/$mugShotImageId.jpg'
      : null;
  String? get microUrl => mugShotImageId != null
      ? 'https://images.igdb.com/igdb/image/upload/t_micro/$mugShotImageId.jpg'
      : null;
  String? get mediumUrl => mugShotImageId != null
      ? 'https://images.igdb.com/igdb/image/upload/t_logo_med/$mugShotImageId.jpg'
      : null;
  String? get largeUrl => mugShotImageId != null
      ? 'https://images.igdb.com/igdb/image/upload/t_720p/$mugShotImageId.jpg'
      : null;

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
  bool get hasMugShot => mugShot != null;
  bool get hasDescription => description != null && description!.isNotEmpty;

  // 🆕 NEW: Image-related helpers
  bool get hasImage => mugShotImageId != null && mugShotImageId!.isNotEmpty;
  bool get hasImageUrl => imageUrl != null;

  // 🆕 NEW: Games-related helpers
  bool get hasLoadedGames => games != null && games!.isNotEmpty;
  int get loadedGameCount => games?.length ?? 0;

  // 🆕 NEW: copyWith method for updating with image data and games
  Character copyWith({
    int? id,
    String? checksum,
    String? name,
    List<String>? akas,
    int? characterGenderId,
    int? characterSpeciesId,
    String? countryName,
    String? description,
    List<int>? gameIds,
    CharacterMugShot? mugShot,
    String? slug,
    String? url,
    DateTime? createdAt,
    DateTime? updatedAt,
    CharacterGenderEnum? genderEnum,
    CharacterSpeciesEnum? speciesEnum,
    String? mugShotImageId,
    List<Game>? games, // 🆕 ADD this
  }) {
    return Character(
      id: id ?? this.id,
      checksum: checksum ?? this.checksum,
      name: name ?? this.name,
      akas: akas ?? this.akas,
      characterGenderId: characterGenderId ?? this.characterGenderId,
      characterSpeciesId: characterSpeciesId ?? this.characterSpeciesId,
      countryName: countryName ?? this.countryName,
      description: description ?? this.description,
      gameIds: gameIds ?? this.gameIds,
      mugShot: mugShot ?? this.mugShot,
      slug: slug ?? this.slug,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      genderEnum: genderEnum ?? this.genderEnum,
      speciesEnum: speciesEnum ?? this.speciesEnum,
      mugShotImageId: mugShotImageId ?? this.mugShotImageId,
      games: games ?? this.games, // 🆕 ADD this
    );
  }

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
    mugShot,
    slug,
    url,
    createdAt,
    updatedAt,
    genderEnum,
    speciesEnum,
    mugShotImageId, // 🆕 ADD this to props
    games, // 🆕 ADD this to props
  ];
}