// ===== GAME TYPE ENTITY =====
// File: lib/domain/entities/game/game_type.dart

import 'package:equatable/equatable.dart';

class GameType extends Equatable {

  const GameType({
    required this.id,
    required this.checksum,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, checksum, type, createdAt, updatedAt];
}
