import 'package:gamer_grove/model/igdb_models/platform_version.dart';

class PlatformVersionReleaseDate {
  int id;
  CategoryEnum? category;
  String? checksum;
  int? createdAt;
  int? date;
  String? human;
  int? month;
  PlatformVersion? platformVersion;
  RegionEnum? region;
  int? updatedAt;
  int? year;

  PlatformVersionReleaseDate({
    required this.id,
    this.category,
    this.checksum,
    this.createdAt,
    this.date,
    this.human,
    this.month,
    this.platformVersion,
    this.region,
    this.updatedAt,
    this.year,
  });

  factory PlatformVersionReleaseDate.fromJson(Map<String, dynamic> json) {
    return PlatformVersionReleaseDate(
      category: CategoryEnumExtension.fromValue(json['category']),
      checksum: json['checksum'],
      createdAt: json['created_at'],
      date: json['date'],
      human: json['human'],
      month: json['m'],
      platformVersion: json['platform_version'] != null
          ? (json['platform_version'] is int
          ? PlatformVersion(id: json['platform_version'])
          : PlatformVersion.fromJson(json['platform_version']))
          : null,
      region: RegionEnumExtension.fromValue(json['region']),
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
