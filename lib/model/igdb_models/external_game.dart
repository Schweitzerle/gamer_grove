
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/platform.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';

class ExternalGame {
  int id;
  CategoryEnum? category;
  String? checksum;
  List<int>? countries;
  int? createdAt;
  Game? game;
  MediaEnum? media;
  String? name;
  PlatformIGDB? platform;
  String? uid;
  int? updatedAt;
  String? url;
  int? year;

  ExternalGame({
    required this.id,
    this.category,
    this.checksum,
    this.countries,
    this.createdAt,
    this.game,
    this.media,
    this.name,
    this.platform,
    this.uid,
    this.updatedAt,
    this.url,
    this.year,
  });

  factory ExternalGame.fromJson(Map<String, dynamic> json) {
    int? categoryValue = json['category'];
    CategoryEnum? category;

    if (categoryValue != null) {
      try {
        category = CategoryEnumExtension.fromValue(categoryValue);
      } catch (e) {
        print('Error parsing category: $e');
        category = null; // Set to an "unknown" category or handle it as needed
      }
    }

    return ExternalGame(
      category: category,
      checksum: json['checksum'],
      countries: json['countries'] != null
          ? List<int>.from(json['countries'])
          : null,
      createdAt: json['created_at'],
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'], gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0))
          : Game.fromJson(json['game'], IGDBApiService.getGameModel(json['game']['id'])))
          : null,
      media: json['media'] != null
          ? MediaEnumExtension.fromValue(json['media'])
          : null,
      name: json['name'],
      platform: json['platform'] != null
          ? (json['platform'] is int
          ? PlatformIGDB(id: json['platform'])
          : PlatformIGDB.fromJson(json['platform']))
          : null,
      uid: json['uid'],
      updatedAt: json['updated_at'],
      url: json['url'],
      year: json['year'], id: json['id'],
    );
  }
}

enum CategoryEnum {
  steam,
  gog,
  youtube,
  microsoft,
  apple,
  twitch,
  android,
  amazonAsin,
  amazonLuna,
  amazonAdg,
  epicGameStore,
  oculus,
  utomik,
  itchIo,
  xboxMarketplace,
  kartridge,
  playstationStoreUs,
  focusEntertainment,
  xboxGamePassUltimateCloud,
  gamejolt,
}

enum MediaEnum {
  digital,
  physical,
}

extension CategoryEnumExtension on CategoryEnum {
  int get value {
    switch (this) {
      case CategoryEnum.steam:
        return 1;
      case CategoryEnum.gog:
        return 5;
      case CategoryEnum.youtube:
        return 10;
      case CategoryEnum.microsoft:
        return 11;
      case CategoryEnum.apple:
        return 13;
      case CategoryEnum.twitch:
        return 14;
      case CategoryEnum.android:
        return 15;
      case CategoryEnum.amazonAsin:
        return 20;
      case CategoryEnum.amazonLuna:
        return 22;
      case CategoryEnum.amazonAdg:
        return 23;
      case CategoryEnum.epicGameStore:
        return 26;
      case CategoryEnum.oculus:
        return 28;
      case CategoryEnum.utomik:
        return 29;
      case CategoryEnum.itchIo:
        return 30;
      case CategoryEnum.xboxMarketplace:
        return 31;
      case CategoryEnum.kartridge:
        return 32;
      case CategoryEnum.playstationStoreUs:
        return 36;
      case CategoryEnum.focusEntertainment:
        return 37;
      case CategoryEnum.xboxGamePassUltimateCloud:
        return 54;
      case CategoryEnum.gamejolt:
        return 55;
    }
  }

  static CategoryEnum fromValue(int value) {
    switch (value) {
      case 1:
        return CategoryEnum.steam;
      case 5:
        return CategoryEnum.gog;
      case 10:
        return CategoryEnum.youtube;
      case 11:
        return CategoryEnum.microsoft;
      case 13:
        return CategoryEnum.apple;
      case 14:
        return CategoryEnum.twitch;
      case 15:
        return CategoryEnum.android;
      case 20:
        return CategoryEnum.amazonAsin;
      case 22:
        return CategoryEnum.amazonLuna;
      case 23:
        return CategoryEnum.amazonAdg;
      case 26:
        return CategoryEnum.epicGameStore;
      case 28:
        return CategoryEnum.oculus;
      case 29:
        return CategoryEnum.utomik;
      case 30:
        return CategoryEnum.itchIo;
      case 31:
        return CategoryEnum.xboxMarketplace;
      case 32:
        return CategoryEnum.kartridge;
      case 36:
        return CategoryEnum.playstationStoreUs;
      case 37:
        return CategoryEnum.focusEntertainment;
      case 54:
        return CategoryEnum.xboxGamePassUltimateCloud;
      case 55:
        return CategoryEnum.gamejolt;
      default:
        throw ArgumentError('Unknown CategoryEnum value: $value');
    }
  }
}

extension MediaEnumExtension on MediaEnum {
  int get value {
    return this.index + 1;
  }

  static MediaEnum fromValue(int value) {
    return MediaEnum.values[value - 1];
  }
}
