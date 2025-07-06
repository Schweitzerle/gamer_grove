// lib/domain/entities/platform.dart (Erweiterte Version - Optional)
import 'package:equatable/equatable.dart';
import 'platform_logo.dart';

// Platform Category Enum (DEPRECATED but still useful)
enum PlatformCategoryEnum {
  console(1),
  arcade(2),
  platform(3),
  operatingSystem(4),
  portableConsole(5),
  computer(6),
  unknown(0);

  const PlatformCategoryEnum(this.value);
  final int value;

  static PlatformCategoryEnum fromValue(int value) {
    return values.firstWhere(
          (category) => category.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case console: return 'Console';
      case arcade: return 'Arcade';
      case platform: return 'Platform';
      case operatingSystem: return 'Operating System';
      case portableConsole: return 'Portable Console';
      case computer: return 'Computer';
      case unknown: return 'Unknown';
    }
  }
}

class Platform extends Equatable {
  final int id;
  final String checksum;
  final String? abbreviation;
  final String? alternativeName;
  final int? generation;
  final String name;
  final int? platformFamilyId;
  final int? platformLogoId;
  final int? platformTypeId;
  final String? slug;
  final String? summary;
  final String? url;
  final List<int> versionIds;
  final List<int> websiteIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // DEPRECATED field but still useful
  final PlatformCategoryEnum? categoryEnum;

  // NEW: Optional full objects (when API returns them)
  final PlatformLogo? platformLogo;

  const Platform({
    required this.id,
    required this.checksum,
    required this.name,
    this.abbreviation,
    this.alternativeName,
    this.generation,
    this.platformFamilyId,
    this.platformLogoId,
    this.platformTypeId,
    this.slug,
    this.summary,
    this.url,
    this.versionIds = const [],
    this.websiteIds = const [],
    this.createdAt,
    this.updatedAt,
    this.categoryEnum,
    this.platformLogo, // NEW
  });

  String get displayName => abbreviation ?? name;

  bool get isConsole => categoryEnum == PlatformCategoryEnum.console;
  bool get isPortable => categoryEnum == PlatformCategoryEnum.portableConsole;
  bool get isPC => categoryEnum == PlatformCategoryEnum.computer;
  bool get isArcade => categoryEnum == PlatformCategoryEnum.arcade;

  // NEW: Helper getter for logo URL
  String? get logoUrl => platformLogo?.thumbUrl;

  @override
  List<Object?> get props => [
    id,
    checksum,
    abbreviation,
    alternativeName,
    generation,
    name,
    platformFamilyId,
    platformLogoId,
    platformTypeId,
    slug,
    summary,
    url,
    versionIds,
    websiteIds,
    createdAt,
    updatedAt,
    categoryEnum,
    platformLogo, // NEW
  ];
}