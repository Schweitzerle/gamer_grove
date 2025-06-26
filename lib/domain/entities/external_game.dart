// lib/domain/entities/external_game.dart
import 'package:equatable/equatable.dart';

enum ExternalGameCategory {
  steam,
  epicGames,
  gog,
  origin,
  uplay,
  battlenet,
  playstation,
  xbox,
  nintendo,
  itch,
  unknown,
}

class ExternalGame extends Equatable {
  final int id;
  final String uid; // External ID
  final String? url;
  final ExternalGameCategory category;
  final String? name;

  const ExternalGame({
    required this.id,
    required this.uid,
    this.url,
    required this.category,
    this.name,
  });

  String get categoryDisplayName {
    switch (category) {
      case ExternalGameCategory.steam:
        return 'Steam';
      case ExternalGameCategory.epicGames:
        return 'Epic Games';
      case ExternalGameCategory.gog:
        return 'GOG';
      case ExternalGameCategory.origin:
        return 'Origin';
      case ExternalGameCategory.uplay:
        return 'Ubisoft Connect';
      case ExternalGameCategory.battlenet:
        return 'Battle.net';
      case ExternalGameCategory.playstation:
        return 'PlayStation Store';
      case ExternalGameCategory.xbox:
        return 'Xbox Store';
      case ExternalGameCategory.nintendo:
        return 'Nintendo eShop';
      case ExternalGameCategory.itch:
        return 'itch.io';
      default:
        return 'External Store';
    }
  }

  @override
  List<Object?> get props => [id, uid, url, category, name];
}
