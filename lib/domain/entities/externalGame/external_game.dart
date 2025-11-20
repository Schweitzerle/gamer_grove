// lib/domain/entities/external_game.dart
import 'package:equatable/equatable.dart';

// External Game Category Enum (maps to external_game_source IDs from IGDB API)
enum ExternalGameCategoryEnum {
  steam(1),
  giantBomb(3),
  gog(5),
  youtube(10),
  microsoft(11),
  apple(13),
  twitch(14),
  android(15),
  amazonAsin(20),
  amazonLuna(22),
  amazonAdg(23),
  epicGameStore(26),
  oculus(28),
  utomik(29),
  itchIo(30),
  xboxMarketplace(31),
  kartridge(32),
  playstationStoreUs(36),
  focusEntertainment(37),
  xboxGamePassUltimateCloud(54),
  gamejolt(55),
  igdb(121),
  unknown(0);

  const ExternalGameCategoryEnum(this.value);
  final int value;

  static ExternalGameCategoryEnum fromValue(int value) {
    return values.firstWhere(
          (category) => category.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case steam: return 'Steam';
      case giantBomb: return 'Giant Bomb';
      case gog: return 'GOG';
      case youtube: return 'YouTube';
      case microsoft: return 'Microsoft Store';
      case apple: return 'App Store';
      case twitch: return 'Twitch';
      case android: return 'Google Play';
      case amazonAsin: return 'Amazon';
      case amazonLuna: return 'Amazon Luna';
      case amazonAdg: return 'Amazon ADG';
      case epicGameStore: return 'Epic Games Store';
      case oculus: return 'Oculus Store';
      case utomik: return 'Utomik';
      case itchIo: return 'itch.io';
      case xboxMarketplace: return 'Xbox Marketplace';
      case kartridge: return 'Kartridge';
      case playstationStoreUs: return 'PlayStation Store';
      case focusEntertainment: return 'Focus Entertainment';
      case xboxGamePassUltimateCloud: return 'Xbox Game Pass Ultimate Cloud';
      case gamejolt: return 'Game Jolt';
      case igdb: return 'IGDB';
      case unknown: return 'Unknown';
    }
  }

  String get iconName {
    switch (this) {
      case steam: return 'steam';
      case gog: return 'gog';
      case epicGameStore: return 'epic';
      case microsoft: return 'microsoft';
      case apple: return 'apple';
      case android: return 'google_play';
      case playstationStoreUs: return 'playstation';
      case xboxMarketplace: return 'xbox';
      case itchIo: return 'itch';
      default: return 'external_link';
    }
  }

  bool get isMainStore {
    return [
      steam,
      gog,
      epicGameStore,
      microsoft,
      apple,
      android,
      playstationStoreUs,
      xboxMarketplace,
    ].contains(this);
  }
}

// External Game Media Enum (DEPRECATED but useful)
enum ExternalGameMediaEnum {
  digital(1),
  physical(2),
  unknown(0);

  const ExternalGameMediaEnum(this.value);
  final int value;

  static ExternalGameMediaEnum fromValue(int value) {
    return values.firstWhere(
          (media) => media.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case digital: return 'Digital';
      case physical: return 'Physical';
      case unknown: return 'Unknown';
    }
  }
}

class ExternalGame extends Equatable {

  const ExternalGame({
    required this.id,
    required this.checksum,
    required this.name,
    required this.uid,
    this.countries = const [],
    this.externalGameSourceId,
    this.gameId,
    this.gameReleaseFormatId,
    this.platformId,
    this.url,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.categoryEnum,
    this.mediaEnum,
  });
  final int id;
  final String checksum;
  final List<int> countries;
  final int? externalGameSourceId;
  final int? gameId;
  final int? gameReleaseFormatId;
  final String name;
  final int? platformId;
  final String uid;
  final String? url;
  final int? year;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // DEPRECATED fields but still very useful
  final ExternalGameCategoryEnum? categoryEnum;
  final ExternalGameMediaEnum? mediaEnum;

  // Helper getters
  String get displayStore {
    if (categoryEnum != null) {
      return categoryEnum!.displayName;
    }
    return 'Unknown Store';
  }

  String get storeIcon {
    if (categoryEnum != null) {
      return categoryEnum!.iconName;
    }
    return 'external_link';
  }

  bool get isMainStore {
    return categoryEnum?.isMainStore ?? false;
  }

  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get isDigital => mediaEnum == ExternalGameMediaEnum.digital;
  bool get isPhysical => mediaEnum == ExternalGameMediaEnum.physical;

  // Build store-specific URLs if needed
  String? get storeUrl {
    if (url != null && url!.isNotEmpty) {
      return url;
    }

    // Fallback URL generation for known stores
    if (categoryEnum != null && uid.isNotEmpty) {
      switch (categoryEnum!) {
        case ExternalGameCategoryEnum.steam:
          return 'https://store.steampowered.com/app/$uid';
        case ExternalGameCategoryEnum.gog:
          return 'https://www.gog.com/game/$uid';
        case ExternalGameCategoryEnum.epicGameStore:
          return 'https://store.epicgames.com/en-US/p/$uid';
        case ExternalGameCategoryEnum.itchIo:
          return 'https://$uid.itch.io';
        default:
          return null;
      }
    }

    return null;
  }

  @override
  List<Object?> get props => [
    id,
    checksum,
    countries,
    externalGameSourceId,
    gameId,
    gameReleaseFormatId,
    name,
    platformId,
    uid,
    url,
    year,
    createdAt,
    updatedAt,
    categoryEnum,
    mediaEnum,
  ];
}