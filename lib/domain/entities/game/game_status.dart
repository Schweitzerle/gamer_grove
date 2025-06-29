// ===== GAME STATUS ENTITY =====
// File: lib/domain/entities/game/game_status.dart

import 'package:equatable/equatable.dart';

class GameStatus extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GameStatus({
    required this.id,
    required this.checksum,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, checksum, name, description, createdAt, updatedAt];
}

// Legacy GameStatus Enum
enum GameStatusEnum {
  released(0),
  alpha(2),
  beta(3),
  earlyAccess(4),
  offline(5),
  cancelled(6),
  rumored(7),
  delisted(8);

  const GameStatusEnum(this.value);
  final int value;

  static GameStatusEnum fromValue(int value) {
    return values.firstWhere((status) => status.value == value, orElse: () => released);
  }
}



