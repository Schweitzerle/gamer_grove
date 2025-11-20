// ===== COMPANY WEBSITE ENTITY =====
// lib/domain/entities/company/company_website.dart
import 'package:equatable/equatable.dart';

enum CompanyWebsiteCategory {
  official(1),
  wikia(2),
  wikipedia(3),
  facebook(4),
  twitter(5),
  twitch(6),
  instagram(8),
  youtube(9),
  iphone(10),
  ipad(11),
  android(12),
  steam(13),
  reddit(14),
  itch(15),
  epicGames(16),
  gog(17),
  discord(18),
  bluesky(19),
  unknown(0);

  const CompanyWebsiteCategory(this.value);
  final int value;

  static CompanyWebsiteCategory fromValue(int value) {
    return values.firstWhere(
          (category) => category.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case official: return 'Official Website';
      case wikia: return 'Wikia';
      case wikipedia: return 'Wikipedia';
      case facebook: return 'Facebook';
      case twitter: return 'Twitter';
      case twitch: return 'Twitch';
      case instagram: return 'Instagram';
      case youtube: return 'YouTube';
      case iphone: return 'iPhone App';
      case ipad: return 'iPad App';
      case android: return 'Android App';
      case steam: return 'Steam';
      case reddit: return 'Reddit';
      case itch: return 'Itch.io';
      case epicGames: return 'Epic Games';
      case gog: return 'GOG';
      case discord: return 'Discord';
      case bluesky: return 'Bluesky';
      default: return 'Unknown';
    }
  }

  bool get isSocialMedia => [facebook, twitter, instagram, youtube, twitch, discord, bluesky].contains(this);
  bool get isStore => [steam, epicGames, gog, itch].contains(this);
  bool get isApp => [iphone, ipad, android].contains(this);
}

class CompanyWebsite extends Equatable { // New reference to Website Type

  const CompanyWebsite({
    required this.id,
    required this.checksum,
    required this.url,
    this.trusted = false,
    this.category = CompanyWebsiteCategory.unknown,
    this.typeId,
  });
  final int id;
  final String checksum;
  final String url;
  final bool trusted;
  final CompanyWebsiteCategory category; // DEPRECATED but still useful
  final int? typeId;

  // Helper getters
  bool get isOfficial => category == CompanyWebsiteCategory.official;
  bool get isSocialMedia => category.isSocialMedia;
  bool get isStore => category.isStore;
  bool get isApp => category.isApp;
  String get displayName => category.displayName;

  @override
  List<Object?> get props => [
    id,
    checksum,
    url,
    trusted,
    category,
    typeId,
  ];
}