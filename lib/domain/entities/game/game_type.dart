// ===== GAME TYPE ENTITY =====
// File: lib/domain/entities/game/game_type.dart

import 'package:equatable/equatable.dart';

class GameType extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GameType({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, checksum, name, createdAt, updatedAt];
}

// Legacy Game Type/Category Enum
enum GameCategoryEnum {
  mainGame(0),
  dlcAddon(1),
  expansion(2),
  bundle(3),
  standaloneExpansion(4),
  mod(5),
  episode(6),
  season(7),
  remake(8),
  remaster(9),
  expandedGame(10),
  port(11),
  fork(12),
  pack(13),
  update(14);

  const GameCategoryEnum(this.value);
  final int value;

  static GameCategoryEnum fromValue(int value) {
    return values.firstWhere((cat) => cat.value == value, orElse: () => mainGame);
  }
}
