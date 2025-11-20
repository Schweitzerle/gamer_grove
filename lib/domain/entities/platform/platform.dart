// ==================================================
// FIXED PLATFORM ENTITY - MIT LOGO SUPPORT
// ==================================================

// lib/domain/entities/platform/platform.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/platform/platform_logo.dart'; // Import für PlatformLogo

enum PlatformCategoryEnum {
  console,
  arcade,
  platform,
  operatingSystem,
  portableConsole,
  computer,
}

class Platform extends Equatable { // Keep for backward compatibility

  const Platform({
    required this.id,
    required this.checksum,
    required this.name,
    required this.slug,
    this.abbreviation,
    this.alternativeName,
    this.generation,
    this.platformFamilyId,
    this.platformLogoId,
    this.logo, // ✅ NEU
    this.platformTypeId,
    this.summary,
    this.url,
    this.versionIds = const [],
    this.websiteIds = const [],
    this.createdAt,
    this.updatedAt,
    this.categoryEnum,
    this.category,
  });
  final int id;
  final String checksum;
  final String name;
  final String? abbreviation;
  final String? alternativeName;
  final int? generation;
  final int? platformFamilyId;
  final int? platformLogoId;
  final PlatformLogo? logo; // ✅ NEU: Logo-Objekt hinzugefügt
  final int? platformTypeId;
  final String slug;
  final String? summary;
  final String? url;
  final List<int> versionIds;
  final List<int> websiteIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PlatformCategoryEnum? categoryEnum;
  final dynamic category;

  // ✅ LOGO URL GETTERS
  String? get logoUrl {
    if (logo?.url != null) {
      // Fix IGDB URLs (add https: if missing)
      final url = logo!.url!;
      if (url.startsWith('//')) {
        return 'https:$url';
      }
      return url;
    }
    return null;
  }

  String? get logoThumbUrl => logo?.thumbUrl;
  String? get logoMedUrl => logo?.logoMedUrl;
  String? get logoMed2xUrl => logo?.logoMed2xUrl;
  String? get logoMicroUrl => logo?.microUrl;

  // ✅ CATEGORY HELPERS
  String get categoryName {
    if (categoryEnum != null) {
      switch (categoryEnum!) {
        case PlatformCategoryEnum.console:
          return 'Console';
        case PlatformCategoryEnum.arcade:
          return 'Arcade';
        case PlatformCategoryEnum.platform:
          return 'Platform';
        case PlatformCategoryEnum.operatingSystem:
          return 'Operating System';
        case PlatformCategoryEnum.portableConsole:
          return 'Handheld';
        case PlatformCategoryEnum.computer:
          return 'Computer';
      }
    }

    // Fallback for dynamic category
    if (category != null) {
      final categoryStr = category.toString().toLowerCase();
      if (categoryStr.contains('console')) return 'Console';
      if (categoryStr.contains('arcade')) return 'Arcade';
      if (categoryStr.contains('operating')) return 'Operating System';
      if (categoryStr.contains('portable')) return 'Handheld';
      if (categoryStr.contains('computer')) return 'Computer';
    }

    return 'Platform';
  }

  // ✅ CONVENIENCE GETTERS
  bool get hasLogo => logo != null;
  bool get isConsole => categoryEnum == PlatformCategoryEnum.console;
  bool get isPC => categoryEnum == PlatformCategoryEnum.operatingSystem ||
      categoryEnum == PlatformCategoryEnum.computer;
  bool get isHandheld => categoryEnum == PlatformCategoryEnum.portableConsole;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    abbreviation,
    alternativeName,
    generation,
    platformFamilyId,
    platformLogoId,
    logo, // ✅ NEU
    platformTypeId,
    slug,
    summary,
    url,
    versionIds,
    websiteIds,
    createdAt,
    updatedAt,
    categoryEnum,
    category,
  ];
}

