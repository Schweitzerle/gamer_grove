// lib/domain/entities/website.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/website/website_type.dart';

class Website extends Equatable {
  final int id;
  final String url;
  final WebsiteCategory category;
  final String? title;

  const Website({
    required this.id,
    required this.url,
    required this.category,
    this.title,
  });

  String get categoryDisplayName {
    switch (category) {
      case WebsiteCategory.official:
        return 'Official Website';
      case WebsiteCategory.steam:
        return 'Steam';
      case WebsiteCategory.epicgames:
        return 'Epic Games';
      case WebsiteCategory.gog:
        return 'GOG';
      case WebsiteCategory.facebook:
        return 'Facebook';
      case WebsiteCategory.twitter:
        return 'Twitter';
      case WebsiteCategory.youtube:
        return 'YouTube';
      case WebsiteCategory.twitch:
        return 'Twitch';
      case WebsiteCategory.instagram:
        return 'Instagram';
      case WebsiteCategory.discord:
        return 'Discord';
      case WebsiteCategory.reddit:
        return 'Reddit';
      case WebsiteCategory.wikia:
        return 'Wikia';
      case WebsiteCategory.wikipedia:
        return 'Wikipedia';
      case WebsiteCategory.itch:
        return 'Itch.io';
      default:
        return 'Website';
    }
  }

  @override
  List<Object?> get props => [id, url, category, title];
}
