
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/platform.dart';
import 'package:gamer_grove/model/igdb_models/release_date_status.dart';

class ReleaseDate {
  int id;
  CategoryEnum? category;
  String? checksum;
  int? createdAt;
  int? date;
  Game? game;
  String? human;
  int? month;
  PlatformIGDB? platform;
  RegionEnum? region;
  ReleaseDateStatus? status;
  int? updatedAt;
  int? year;

  ReleaseDate({
    required this.id,
    this.category,
    this.checksum,
    this.createdAt,
    this.date,
    this.game,
    this.human,
    this.month,
    this.platform,
    this.region,
    this.status,
    this.updatedAt,
    this.year,
  });

  factory ReleaseDate.fromJson(Map<String, dynamic> json) {
    return ReleaseDate(
      category: json['category'] != null ? CategoryEnumExtension.fromValue(json['category']) :null,
      checksum: json['checksum'],
      createdAt: json['created_at'],
      date: json['date'],
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'])
          : Game.fromJson(json['game']))
          : null,
      human: json['human'],
      month: json['m'],
      platform: json['platform'] != null
          ? (json['platform'] is int
          ? PlatformIGDB(id: json['platform'])
          : PlatformIGDB.fromJson(json['platform']))
          : null,
      region: json['region'] != null ? RegionEnumExtension.fromValue(json['region']) : null,
      status: json['status'] != null
          ? (json['status'] is int
          ? ReleaseDateStatus(id: json['status'])
          : ReleaseDateStatus.fromJson(json['status']))
          : null,
      updatedAt: json['updated_at'],
      year: json['y'], id: json['id'],
    );
  }
}

enum CategoryEnum {
  yyyymmdd,
  yyyymm,
  yyyy,
  yyyymq1,
  yyyymq2,
  yyyymq3,
  yyyymq4,
  tbd,
}

extension CategoryEnumExtension on CategoryEnum {
  int get value {
    return this.index;
  }

  static CategoryEnum fromValue(int value) {
    return CategoryEnum.values[value];
  }
}

enum RegionEnum {
  europe,
  northAmerica,
  australia,
  newZealand,
  japan,
  china,
  asia,
  worldwide,
  korea,
  brazil,
}

extension RegionEnumExtension on RegionEnum {
  int get value {
    return this.index + 1;
  }

  static RegionEnum fromValue(int value) {
    return RegionEnum.values[value - 1];
  }
}
