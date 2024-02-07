import 'package:gamer_grove/model/igdb_models/platform_family.dart';
import 'package:gamer_grove/model/igdb_models/platform_logo.dart';
import 'package:gamer_grove/model/igdb_models/platform_version.dart';
import 'package:gamer_grove/model/igdb_models/platform_website.dart';

class PlatformIGDB {
  int id;
  String? abbreviation;
  String? alternativeName;
  CategoryEnum? category;
  String? checksum;
  int? createdAt;
  int? generation;
  String? name;
  PlatformFamily? platformFamily;
  PlatformLogo? platformLogo;
  String? slug;
  String? summary;
  int? updatedAt;
  String? url;
  List<PlatformVersion>? versions;
  List<PlatformWebsite>? websites;

  PlatformIGDB({
    required this.id,
    this.abbreviation,
    this.alternativeName,
    this.category,
    this.checksum,
    this.createdAt,
    this.generation,
    this.name,
    this.platformFamily,
    this.platformLogo,
    this.slug,
    this.summary,
    this.updatedAt,
    this.url,
    this.versions,
    this.websites,
  });

  factory PlatformIGDB.fromJson(Map<String, dynamic> json) {
    return PlatformIGDB(
      abbreviation: json['abbreviation'],
      alternativeName: json['alternative_name'],
      category: json['category'] != null
          ? CategoryEnumExtension.fromValue(json['category'])
          : null,
      checksum: json['checksum'],
      createdAt: json['created_at'],
      generation: json['generation'],
      name: json['name'],
      platformFamily: json['platform_family'] != null
          ? (json['platform_family'] is int
          ? PlatformFamily(id: json['platform_family'])
          : PlatformFamily.fromJson(json['platform_family']))
          : null,
      platformLogo: json['platform_logo'] != null
          ? (json['platform_logo'] is int
          ? PlatformLogo(id: json['platform_logo'])
          : PlatformLogo.fromJson(json['platform_logo']))
          : null,
      slug: json['slug'],
      summary: json['summary'],
      updatedAt: json['updated_at'],
      url: json['url'],
      versions: json['versions'] != null
          ? List<PlatformVersion>.from(
        json['versions'].map((platformVersion) {
          if (platformVersion is int) {
            return PlatformVersion(id: platformVersion);
          } else {
            return PlatformVersion.fromJson(platformVersion);
          }
        }),
      )
          : null,
      websites: json['websites'] != null
          ? List<PlatformWebsite>.from(
        json['websites'].map((platformWebsite) {
          if (platformWebsite is int) {
            return PlatformWebsite(id: platformWebsite);
          } else {
            return PlatformWebsite.fromJson(platformWebsite);
          }
        }),
      )
          : null,
      id: json['id'],
    );
  }
}

enum CategoryEnum {
  CONSOLE,
  ARCADE,
  PLATFORM,
  OPERATING_SYSTEM,
  PORTABLE_CONSOLE,
  COMPUTER,
}

extension CategoryEnumExtension on CategoryEnum {
  int get value {
    return this.index + 1;
  }

  static CategoryEnum fromValue(int value) {
    return CategoryEnum.values[value - 1];
  }
}
