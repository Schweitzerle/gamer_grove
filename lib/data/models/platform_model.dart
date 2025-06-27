// ===== PLATFORM MODEL =====
// lib/data/models/platform_model.dart
import '../../domain/entities/platform.dart';

class PlatformModel extends Platform {
  const PlatformModel({
    required super.id,
    required super.name,
    required super.abbreviation,
    super.logoUrl,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    return PlatformModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ??
          json['name']?.toString() ??
          'UNK',
      logoUrl: _extractLogoUrl(json),
    );
  }

  /// Extrahiert die Logo-URL aus verschiedenen möglichen JSON-Strukturen
  static String? _extractLogoUrl(Map<String, dynamic> json) {
    // Direkte URL
    if (json['logo_url'] is String) {
      return _formatImageUrl(json['logo_url']);
    }

    // Platform Logo Objekt
    if (json['platform_logo'] is Map) {
      final logoObj = json['platform_logo'] as Map<String, dynamic>;
      if (logoObj['url'] is String) {
        return _formatImageUrl(logoObj['url']);
      }
    }

    // Logo Objekt
    if (json['logo'] is Map) {
      final logoObj = json['logo'] as Map<String, dynamic>;
      if (logoObj['url'] is String) {
        return _formatImageUrl(logoObj['url']);
      }
    }

    return null;
  }

  /// Formatiert die Bild-URL korrekt (fügt https: hinzu falls nötig)
  static String _formatImageUrl(String url) {
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    return url;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'logo_url': logoUrl,
    };
  }

  /// Erstellt ein Mock-Platform für Tests
  factory PlatformModel.mock({
    int id = 1,
    String name = 'PC',
    String? abbreviation,
    String? logoUrl,
  }) {
    return PlatformModel(
      id: id,
      name: name,
      abbreviation: abbreviation ?? name,
      logoUrl: logoUrl,
    );
  }

  /// Vordefinierte beliebte Plattformen
  static const List<PlatformModel> popularPlatforms = [
    PlatformModel(id: 6, name: 'PC (Microsoft Windows)', abbreviation: 'PC'),
    PlatformModel(id: 167, name: 'PlayStation 5', abbreviation: 'PS5'),
    PlatformModel(id: 169, name: 'Xbox Series X|S', abbreviation: 'XSX|S'),
    PlatformModel(id: 130, name: 'Nintendo Switch', abbreviation: 'Switch'),
    PlatformModel(id: 48, name: 'PlayStation 4', abbreviation: 'PS4'),
    PlatformModel(id: 49, name: 'Xbox One', abbreviation: 'XOne'),
  ];

  /// Gibt eine Platform anhand der ID zurück
  static PlatformModel? getPlatformById(int id) {
    try {
      return popularPlatforms.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

extension PlatformListExtensions on List<Platform> {
  /// Findet eine Platform anhand der ID
  Platform? findById(int id) {
    try {
      return firstWhere((platform) => platform.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Findet eine Platform anhand des Namens
  Platform? findByName(String name) {
    try {
      return firstWhere((platform) => platform.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Gibt alle Platform-Namen als String-Liste zurück
  List<String> get names => map((platform) => platform.name).toList();

  /// Gibt alle Platform-Abkürzungen als String-Liste zurück
  List<String> get abbreviations => map((platform) => platform.abbreviation).toList();

  /// Filtert Plattformen nach Console/PC
  List<Platform> get consoles => where((platform) =>
  !platform.name.toLowerCase().contains('pc') &&
      !platform.name.toLowerCase().contains('windows')).toList();

  List<Platform> get pcPlatforms => where((platform) =>
  platform.name.toLowerCase().contains('pc') ||
      platform.name.toLowerCase().contains('windows')).toList();
}