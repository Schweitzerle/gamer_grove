// ==================================================
// FEHLENDE MODEL-KLASSEN
// ==================================================

// lib/data/models/game_engine_model.dart
import '../../domain/entities/game_engine.dart';

class GameEngineModel extends GameEngine {
  const GameEngineModel({
    required super.id,
    required super.name,
    super.description,
    super.logoUrl,
    super.url,
  });

  factory GameEngineModel.fromJson(Map<String, dynamic> json) {
    return GameEngineModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Engine',
      description: json['description'],
      logoUrl: _parseLogoUrl(json['logo']),
      url: json['url'],
    );
  }

  static String? _parseLogoUrl(dynamic logo) {
    if (logo is Map && logo['url'] != null) {
      final url = logo['url'] as String;
      return url.startsWith('//') ? 'https:$url' : url;
    }
    return null;
  }
}

