// lib/data/models/website_model.dart
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
      title: _generateTitle(json['category']), // Generate title from category
    );
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
}