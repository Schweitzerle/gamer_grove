// lib/data/models/platform_model.dart
import '../../../domain/entities/platform/platform.dart';

class PlatformModel extends Platform {
  const PlatformModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.abbreviation,
    super.alternativeName,
    super.generation,
    super.platformFamilyId,
    super.platformLogoId,
    super.platformTypeId,
    super.slug,
    super.summary,
    super.url,
    super.versionIds,
    super.websiteIds,
    super.createdAt,
    super.updatedAt,
    super.categoryEnum,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    try {
      return PlatformModel(
        id: json['id'] ?? 0,
        checksum: json['checksum'] ?? '',
        name: json['name'] ?? '',
        abbreviation: json['abbreviation'],
        alternativeName: json['alternative_name'],
        generation: json['generation'],
        platformFamilyId: _parseReferenceId(json['platform_family']),
        // FIX: Handle platform_logo as either ID or full object
        platformLogoId: _parseReferenceId(json['platform_logo']),
        // FIX: Handle platform_type as either ID or full object
        platformTypeId: _parseReferenceId(json['platform_type']),
        slug: json['slug'],
        summary: json['summary'],
        url: json['url'],
        versionIds: _parseIdList(json['versions']),
        websiteIds: _parseIdList(json['websites']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
        categoryEnum: _parseCategoryEnum(json['category']),
      );
    } catch (e) {
      print('❌ PlatformModel.fromJson failed: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  // NEW: Helper method to extract ID from either int or object
  static int? _parseReferenceId(dynamic data) {
    if (data is int) {
      return data;
    } else if (data is Map && data['id'] is int) {
      return data['id'];
    }
    return null;
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

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  static PlatformCategoryEnum? _parseCategoryEnum(dynamic category) {
    if (category is int) {
      return PlatformCategoryEnum.fromValue(category);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'abbreviation': abbreviation,
      'alternative_name': alternativeName,
      'generation': generation,
      'name': name,
      'platform_family': platformFamilyId,
      'platform_logo': platformLogoId,
      'platform_type': platformTypeId,
      'slug': slug,
      'summary': summary,
      'url': url,
      'versions': versionIds,
      'websites': websiteIds,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': categoryEnum?.value,
    };
  }
}