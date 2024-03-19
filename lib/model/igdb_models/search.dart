import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/collection.dart';
import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/igdb_models/platform.dart';
import 'package:gamer_grove/model/igdb_models/theme.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';
import 'game.dart';

class Search {
  int id;
  String? alternativeName;
  String? checksum;
  String? description;
  String? name;
  int? publishedAt;
  int? testDummy;
  Character? character;
  Collection? collection;
  Company? company;
  Game? game;
  PlatformIGDB? platform;
  ThemeIDGB? theme;

  Search({
    required this.id,
    this.alternativeName,
    this.checksum,
    this.description,
    this.name,
    this.publishedAt,
    this.testDummy,
    this.character,
    this.collection,
    this.company,
    this.game,
    this.platform,
    this.theme,
  });

  factory Search.fromJson(Map<String, dynamic> json) {
    return Search(
      alternativeName: json['alternative_name'],
      checksum: json['checksum'],
      description: json['description'],
      name: json['name'],
      publishedAt: json['published_at'],
      testDummy: json['test_dummy'],
      character: json['character'] != null
          ? (json['character'] is int
          ? Character(id: json['character'])
          : Character.fromJson(json['character']))
          : null,
      collection: json['collection'] != null
          ? (json['collection'] is int
          ? Collection(id: json['collection'])
          : Collection.fromJson(json['collection']))
          : null,
      company: json['company'] != null
          ? (json['company'] is int
          ? Company(id: json['company'])
          : Company.fromJson(json['company']))
          : null,
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'], gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0))
          : Game.fromJson(json['game'], IGDBApiService.getGameModel(json['game']['id'])))
          : null,
      platform: json['platform'] != null
          ? (json['platform'] is int
          ? PlatformIGDB(id: json['platform'])
          : PlatformIGDB.fromJson(json['platform']))
          : null,
      theme: json['theme'] != null
          ? (json['theme'] is int
          ? ThemeIDGB(id: json['theme'])
          : ThemeIDGB.fromJson(json['theme']))
          : null, id: json['id'],
    );
  }
}
