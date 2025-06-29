// lib/domain/entities/website_type.dart
import 'package:equatable/equatable.dart';

class WebsiteType extends Equatable {
  final int id;
  final String checksum;
  final String type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WebsiteType({
    required this.id,
    required this.checksum,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  // Helper to get icon for website type
  String? get iconName {
    switch (type.toLowerCase()) {
      case 'official':
        return 'web';
      case 'wikia':
      case 'wikipedia':
        return 'book';
      case 'facebook':
        return 'facebook';
      case 'twitter':
        return 'twitter';
      case 'twitch':
        return 'videocam';
      case 'instagram':
        return 'camera_alt';
      case 'youtube':
        return 'play_circle';
      case 'steam':
        return 'games';
      case 'reddit':
        return 'forum';
      case 'discord':
        return 'chat';
      case 'bluesky':
        return 'cloud';
      case 'epicgames':
      case 'gog':
        return 'storefront';
      case 'iphone':
      case 'ipad':
        return 'phone_iphone';
      case 'android':
        return 'android';
      default:
        return 'link';
    }
  }

  // Helper to check if it's a social media type
  bool get isSocialMedia => [
    'facebook', 'twitter', 'instagram',
    'youtube', 'twitch', 'reddit',
    'discord', 'bluesky'
  ].contains(type.toLowerCase());

  // Helper to check if it's a store/marketplace
  bool get isStore => [
    'steam', 'epicgames', 'gog',
    'iphone', 'ipad', 'android'
  ].contains(type.toLowerCase());

  // Helper to check if it's a wiki/info site
  bool get isWiki => [
    'wikia', 'wikipedia'
  ].contains(type.toLowerCase());

  @override
  List<Object?> get props => [
    id,
    checksum,
    type,
    createdAt,
    updatedAt,
  ];
}

// Website Category Enum (für Legacy Support)
enum WebsiteCategory {
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
  epicgames(16),
  gog(17),
  discord(18),
  bluesky(19);

  const WebsiteCategory(this.value);
  final int value;

  static WebsiteCategory fromValue(int value) {
    return values.firstWhere(
          (category) => category.value == value,
      orElse: () => official,
    );
  }

  String get typeName {
    return name;
  }
}