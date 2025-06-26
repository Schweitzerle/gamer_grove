// lib/data/models/external_game_model.dart
import '../../domain/entities/external_game.dart';

class ExternalGameModel extends ExternalGame {
  const ExternalGameModel({
    required super.id,
    required super.uid,
    super.url,
    required super.category,
    super.name,
  });

  factory ExternalGameModel.fromJson(Map<String, dynamic> json) {
    return ExternalGameModel(
      id: json['id'] ?? 0,
      uid: json['uid'] ?? '',
      url: json['url'],
      category: _parseCategory(json['category']),
      name: json['name'],
    );
  }

  static ExternalGameCategory _parseCategory(dynamic category) {
    if (category is int) {
      switch (category) {
        case 1: return ExternalGameCategory.steam;
        case 5: return ExternalGameCategory.gog;
        case 11: return ExternalGameCategory.origin;
        case 13: return ExternalGameCategory.epicGames;
        case 26: return ExternalGameCategory.uplay;
        case 28: return ExternalGameCategory.battlenet;
        case 36: return ExternalGameCategory.playstation;
        case 37: return ExternalGameCategory.xbox;
        case 38: return ExternalGameCategory.nintendo;
        case 92: return ExternalGameCategory.itch;
        default: return ExternalGameCategory.unknown;
      }
    }
    return ExternalGameCategory.unknown;
  }
}