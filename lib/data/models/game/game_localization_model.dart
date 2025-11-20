// ===== GAME LOCALIZATION MODEL =====
// lib/data/models/game_localization_model.dart
import 'package:gamer_grove/domain/entities/game/game_localization.dart';

class GameLocalizationModel extends GameLocalization {
  const GameLocalizationModel({
    required super.id,
    required super.name,
    super.region,
  });

  factory GameLocalizationModel.fromJson(Map<String, dynamic> json) {
    return GameLocalizationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      region: _parseRegion(json['region']),
    );
  }

  static LocalizationRegion _parseRegion(dynamic region) {
    if (region is int) {
      switch (region) {
        case 1: return LocalizationRegion.europe;
        case 2: return LocalizationRegion.northAmerica;
        case 3: return LocalizationRegion.australia;
        case 4: return LocalizationRegion.newZealand;
        case 5: return LocalizationRegion.japan;
        case 6: return LocalizationRegion.china;
        case 7: return LocalizationRegion.asia;
        case 8: return LocalizationRegion.worldwide;
        case 9: return LocalizationRegion.korea;
        case 10: return LocalizationRegion.brazil;
        default: return LocalizationRegion.unknown;
      }
    }
    return LocalizationRegion.unknown;
  }
}
