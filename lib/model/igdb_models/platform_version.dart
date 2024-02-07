import 'package:gamer_grove/model/igdb_models/platform_logo.dart';
import 'package:gamer_grove/model/igdb_models/platform_version_company.dart';
import 'package:gamer_grove/model/igdb_models/platform_version_release_date.dart';

class PlatformVersion {
  int id;
  final String? checksum;
  final List<PlatformVersionCompany>? platformVersionCompanyIds;
  final String? connectivity;
  final String? cpu;
  final String? graphics;
  final PlatformVersionCompany? mainManufacturerId;
  final String? media;
  final String? memory;
  final String? name;
  final String? os;
  final String? output;
  final PlatformLogo? platformLogoId;
  final List<PlatformVersionReleaseDate>? platformVersionReleaseDateIds;
  final String? resolutions;
  final String? slug;
  final String? sound;
  final String? storage;
  final String? summary;
  final String? url;

  PlatformVersion({
    required this.id,
    this.checksum,
    this.platformVersionCompanyIds,
    this.connectivity,
    this.cpu,
    this.graphics,
    this.mainManufacturerId,
    this.media,
    this.memory,
    this.name,
    this.os,
    this.output,
    this.platformLogoId,
    this.platformVersionReleaseDateIds,
    this.resolutions,
    this.slug,
    this.sound,
    this.storage,
    this.summary,
    this.url,
  });

  factory PlatformVersion.fromJson(Map<String, dynamic> json) {
    return PlatformVersion(
      checksum: json['checksum'],
      platformVersionCompanyIds: json['platform_version_company_ids'] != null
          ? List<PlatformVersionCompany>.from(
        json['platform_version_company_ids'].map((platformVersionCompany) {
          if (platformVersionCompany is int) {
            return PlatformVersionCompany(id: platformVersionCompany);
          } else {
            return PlatformVersionCompany.fromJson(platformVersionCompany);
          }
        }),
      )
          : null,
      connectivity: json['connectivity'],
      cpu: json['cpu'],
      graphics: json['graphics'],
      mainManufacturerId: json['main_manufacturer'] != null
          ? (json['main_manufacturer'] is int
          ? PlatformVersionCompany(id: json['main_manufacturer'])
          : PlatformVersionCompany.fromJson(json['main_manufacturer']))
          : null,
      media: json['media'],
      memory: json['memory'],
      name: json['name'],
      os: json['os'],
      output: json['output'],
      platformLogoId: json['platform_logo'] != null
          ? (json['platform_logo'] is int
          ? PlatformLogo(id: json['platform_logo'])
          : PlatformLogo.fromJson(json['platform_logo']))
          : null,
      platformVersionReleaseDateIds: json['platform_version_release_dates'] != null
          ? List<PlatformVersionReleaseDate>.from(
        json['platform_version_release_dates'].map((platformVersionReleaseDate) {
          if (platformVersionReleaseDate is int) {
            return PlatformVersionReleaseDate(id: platformVersionReleaseDate);
          } else {
            return PlatformVersionReleaseDate.fromJson(platformVersionReleaseDate);
          }
        }),
      )
          : null,
      resolutions: json['resolutions'],
      slug: json['slug'],
      sound: json['sound'],
      storage: json['storage'],
      summary: json['summary'],
      url: json['url'], id: json['id'],
    );
  }
}
