// ===== PLATFORM VERSION RELEASE DATE MODEL =====
// File: lib/data/models/platform/platform_version_release_date_model.dart

import '../../../domain/entities/date/date_format.dart';
import '../../../domain/entities/platform/platform_version_release_date.dart';
import '../../../domain/entities/region.dart';

class PlatformVersionReleaseDateModel extends PlatformVersionReleaseDate {
  const PlatformVersionReleaseDateModel({
    required super.id,
    required super.checksum,
    super.date,
    super.dateFormatId,
    super.human,
    super.month,
    super.platformVersionId,
    super.releaseRegionId,
    super.year,
    super.createdAt,
    super.updatedAt,
    super.category,
    super.region,
  });

  factory PlatformVersionReleaseDateModel.fromJson(Map<String, dynamic> json) {
    return PlatformVersionReleaseDateModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      date: _parseDate(json['date']),
      dateFormatId: json['date_format'],
      human: json['human'],
      month: json['m'],
      platformVersionId: json['platform_version'],
      releaseRegionId: json['release_region'],
      year: json['y'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      category: _parseDateCategory(json['category']),
      region: _parseRegion(json['region']),
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    } else if (date is String) {
      return DateTime.tryParse(date);
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  static DateFormatCategory? _parseDateCategory(dynamic category) {
    if (category is int) {
      return DateFormatCategory.fromValue(category);
    }
    return null;
  }

  static RegionEnum? _parseRegion(dynamic region) {
    if (region is int) {
      return RegionEnum.fromValue(region);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'date': date != null ? date!.millisecondsSinceEpoch ~/ 1000 : null,
      'date_format': dateFormatId,
      'human': human,
      'm': month,
      'platform_version': platformVersionId,
      'release_region': releaseRegionId,
      'y': year,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': category?.value,
      'region': region?.value,
    };
  }
}
