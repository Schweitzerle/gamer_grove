// ==================================================
// FIXED PLATFORM MODEL - MIT LOGO MAPPING
// ==================================================

// lib/data/models/platform/platform_model.dart
import '../../../domain/entities/platform/platform.dart';
import '../../../domain/entities/platform/platform_logo.dart';
import 'platform_logo_model.dart';

class PlatformModel extends Platform {
  const PlatformModel({
    required super.id,
    required super.checksum,
    required super.name,
    required super.slug,
    super.abbreviation,
    super.alternativeName,
    super.generation,
    super.platformFamilyId,
    super.platformLogoId,
    super.logo, // ✅ NEU
    super.platformTypeId,
    super.summary,
    super.url,
    super.versionIds,
    super.websiteIds,
    super.createdAt,
    super.updatedAt,
    super.categoryEnum,
    super.category,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔧 PlatformModel.fromJson: ${json['name']} (ID: ${json['id']})');

      // ✅ PARSE PLATFORM LOGO OBJECT
      PlatformLogo? logo;
      if (json['platform_logo'] != null) {
        if (json['platform_logo'] is Map<String, dynamic>) {
          // Full logo object from API
          try {
            logo = PlatformLogoModel.fromJson(json['platform_logo']);
            print('🔧 Logo parsed: ${logo.url}');
          } catch (e) {
            print('❌ Error parsing logo: $e');
          }
        }
      }

      return PlatformModel(
        id: json['id'] ?? 0,
        checksum: json['checksum'] ?? '',
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
        abbreviation: json['abbreviation'],
        alternativeName: json['alternative_name'],
        generation: json['generation'],
        platformFamilyId: _parseReferenceId(json['platform_family']),
        platformLogoId: _parseReferenceId(json['platform_logo']),
        logo: logo, // ✅ NEU: Logo-Objekt hinzugefügt
        platformTypeId: _parseReferenceId(json['platform_type']),
        summary: json['summary'],
        url: json['url'],
        versionIds: _parseIdList(json['versions']),
        websiteIds: _parseIdList(json['websites']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
        categoryEnum: _parseCategoryEnum(json['category']),
        category: json['category'], // Keep raw for debugging
      );
    } catch (e, stackTrace) {
      print('❌ PlatformModel.fromJson failed: $e');
      print('📄 JSON data: $json');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ✅ HELPER METHODS
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
    if (date is String && date.isNotEmpty) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  static PlatformCategoryEnum? _parseCategoryEnum(dynamic category) {
    if (category is int) {
      try {
        // IGDB categories: 1=console, 2=arcade, 3=platform, 4=operating_system, 5=portable_console, 6=computer
        switch (category) {
          case 1:
            return PlatformCategoryEnum.console;
          case 2:
            return PlatformCategoryEnum.arcade;
          case 3:
            return PlatformCategoryEnum.platform;
          case 4:
            return PlatformCategoryEnum.operatingSystem;
          case 5:
            return PlatformCategoryEnum.portableConsole;
          case 6:
            return PlatformCategoryEnum.computer;
          default:
            return null;
        }
      } catch (e) {
        print('🔧 Error parsing category enum: $e');
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'checksum': checksum,
    'name': name,
    'abbreviation': abbreviation,
    'alternative_name': alternativeName,
    'generation': generation,
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
    'category': categoryEnum?.index != null ? categoryEnum!.index + 1 : null,
  };
}
