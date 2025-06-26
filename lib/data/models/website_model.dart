// lib/data/models/website_model.dart
import '../../domain/entities/website.dart';

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
      title: json['title'],
    );
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
        case 16: return WebsiteCategory.epicGames;
        case 17: return WebsiteCategory.gog;
        case 18: return WebsiteCategory.discord;
        default: return WebsiteCategory.unknown;
      }
    }
    return WebsiteCategory.unknown;
  }
}