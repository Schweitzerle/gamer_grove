// ===== GAME MODE MODEL =====
// lib/data/models/game_mode_model.dart
import '../../domain/entities/game_mode.dart';

class GameModeModel extends GameMode {
  const GameModeModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory GameModeModel.fromJson(Map<String, dynamic> json) {
    return GameModeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? json['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }

  /// Erstellt ein Mock-GameMode für Tests
  factory GameModeModel.mock({
    int id = 1,
    String name = 'Single player',
    String? slug,
  }) {
    return GameModeModel(
      id: id,
      name: name,
      slug: slug ?? name.toLowerCase().replaceAll(' ', '-'),
    );
  }

  /// Vordefinierte Standard-Game-Modes basierend auf IGDB
  static const List<GameModeModel> standardGameModes = [
    GameModeModel(id: 1, name: 'Single player', slug: 'singleplayer'),
    GameModeModel(id: 2, name: 'Multiplayer', slug: 'multiplayer'),
    GameModeModel(id: 3, name: 'Co-operative', slug: 'co-operative'),
    GameModeModel(id: 4, name: 'Split screen', slug: 'split-screen'),
    GameModeModel(id: 5, name: 'MMO', slug: 'mmo'),
    GameModeModel(id: 6, name: 'Battle Royale', slug: 'battle-royale'),
  ];

  /// Gibt einen Game Mode anhand der ID zurück
  static GameModeModel? getGameModeById(int id) {
    try {
      return standardGameModes.firstWhere((gm) => gm.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Prüft ob es sich um einen Multiplayer-Mode handelt
  bool get isMultiplayer {
    return id == 2 || // Multiplayer
        id == 3 || // Co-operative
        id == 4 || // Split screen
        id == 5 || // MMO
        id == 6;   // Battle Royale
  }

  /// Prüft ob es sich um einen Single-Player-Mode handelt
  bool get isSinglePlayer => id == 1;

  /// Prüft ob es sich um einen kooperativen Mode handelt
  bool get isCooperative => id == 3 || id == 4; // Co-op oder Split screen
}

extension GameModeListExtensions on List<GameMode> {
  /// Findet einen Game Mode anhand der ID
  GameMode? findById(int id) {
    try {
      return firstWhere((mode) => mode.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Prüft ob Multiplayer-Modi verfügbar sind
  bool get hasMultiplayer {
    return any((mode) => mode is GameModeModel && mode.isMultiplayer);
  }

  /// Prüft ob Single-Player verfügbar ist
  bool get hasSinglePlayer {
    return any((mode) => mode is GameModeModel && mode.isSinglePlayer);
  }

  /// Prüft ob kooperative Modi verfügbar sind
  bool get hasCooperative {
    return any((mode) => mode is GameModeModel && mode.isCooperative);
  }

  /// Gibt alle Mode-Namen als String-Liste zurück
  List<String> get names => map((mode) => mode.name).toList();
}