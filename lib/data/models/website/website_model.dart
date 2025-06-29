// ===========================================
// ERWEITERTE WEBSITEMODEL MIT TOJSON
// ===========================================
// lib/data/models/website/website_model.dart
import '../../../domain/entities/website/website.dart';
import '../../../domain/entities/website/website_type.dart';

class WebsiteModel extends Website {
  const WebsiteModel({
    required super.id,
    required super.url,
    required super.category,
    super.title,
  });

  factory WebsiteModel.fromJson(Map<String, dynamic> json) {
    return WebsiteModel(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      category: _parseCategory(json['category']),
      title: _generateTitle(json['category']) ?? json['title'], // Use provided title or generate
    );
  }

  // *** NEUE TOJSON METHODE ***
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'category': category.value,
      'title': title,
    };
  }

  static String? _generateTitle(dynamic category) {
    if (category is int) {
      switch (category) {
        case 1: return 'Official Website';
        case 2: return 'Wikia';
        case 3: return 'Wikipedia';
        case 4: return 'Facebook';
        case 5: return 'Twitter';
        case 6: return 'Twitch';
        case 8: return 'Instagram';
        case 9: return 'YouTube';
        case 13: return 'Steam';
        case 14: return 'Reddit';
        case 15: return 'itch.io';
        case 16: return 'Epic Games';
        case 17: return 'GOG';
        case 18: return 'Discord';
        case 19: return 'Bluesky';
        default: return 'Website';
      }
    }
    return 'Website';
  }

  static WebsiteCategory _parseCategory(dynamic category) {
    if (category is int) {
      switch (category) {
        case 1: return WebsiteCategory.official;
        case 2: return WebsiteCategory.wikia;
        case 3: return WebsiteCategory.wikipedia;
        case 4: return WebsiteCategory.facebook;
        case 5: return WebsiteCategory.twitter;
        case 6: return WebsiteCategory.twitch;
        case 8: return WebsiteCategory.instagram;
        case 9: return WebsiteCategory.youtube;
        case 13: return WebsiteCategory.steam;
        case 16: return WebsiteCategory.epicgames;
        case 17: return WebsiteCategory.gog;
        case 18: return WebsiteCategory.discord;
        default: return WebsiteCategory.official;
      }
    }
    return WebsiteCategory.official;
  }

  // Helper method to create website from URL and category
  factory WebsiteModel.fromUrl(String url, WebsiteCategory category, {int? id, String? customTitle}) {
    return WebsiteModel(
      id: id ?? 0,
      url: url,
      category: category,
      title: customTitle ?? _generateTitle(category.value),
    );
  }

  // Helper method to get display icon for website category
  String get iconName {
    switch (category) {
      case WebsiteCategory.steam: return 'steam';
      case WebsiteCategory.facebook: return 'facebook';
      case WebsiteCategory.twitter: return 'twitter';
      case WebsiteCategory.instagram: return 'instagram';
      case WebsiteCategory.youtube: return 'youtube';
      case WebsiteCategory.twitch: return 'twitch';
      case WebsiteCategory.discord: return 'discord';
      case WebsiteCategory.epicgames: return 'epic';
      case WebsiteCategory.gog: return 'gog';
      default: return 'link';
    }
  }

  // Helper method to check if website is a main store
  bool get isMainStore {
    return [
      WebsiteCategory.steam,
      WebsiteCategory.epicgames,
      WebsiteCategory.gog,
    ].contains(category);
  }
}

