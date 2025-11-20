// ===== PLATFORM VERSION MODEL =====
// File: lib/data/models/platform/platform_version_model.dart

import 'package:gamer_grove/domain/entities/platform/platform_version.dart';

class PlatformVersionModel extends PlatformVersion {
  const PlatformVersionModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.connectivity,
    super.cpu,
    super.graphics,
    super.mainManufacturerId,
    super.media,
    super.memory,
    super.os,
    super.output,
    super.platformLogoId,
    super.platformVersionReleaseDateIds,
    super.resolutions,
    super.slug,
    super.sound,
    super.storage,
    super.summary,
    super.url,
    super.companyIds,
  });

  factory PlatformVersionModel.fromJson(Map<String, dynamic> json) {
    return PlatformVersionModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      connectivity: json['connectivity'],
      cpu: json['cpu'],
      graphics: json['graphics'],
      mainManufacturerId: json['main_manufacturer'],
      media: json['media'],
      memory: json['memory'],
      os: json['os'],
      output: json['output'],
      platformLogoId: json['platform_logo'],
      platformVersionReleaseDateIds: _parseIdList(json['platform_version_release_dates']),
      resolutions: json['resolutions'],
      slug: json['slug'],
      sound: json['sound'],
      storage: json['storage'],
      summary: json['summary'],
      url: json['url'],
      companyIds: _parseIdList(json['companies']),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'connectivity': connectivity,
      'cpu': cpu,
      'graphics': graphics,
      'main_manufacturer': mainManufacturerId,
      'media': media,
      'memory': memory,
      'name': name,
      'os': os,
      'output': output,
      'platform_logo': platformLogoId,
      'platform_version_release_dates': platformVersionReleaseDateIds,
      'resolutions': resolutions,
      'slug': slug,
      'sound': sound,
      'storage': storage,
      'summary': summary,
      'url': url,
      'companies': companyIds,
    };
  }
}

