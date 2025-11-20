// ===== GAME STATUS ENTITY =====
// File: lib/domain/entities/game/game_status.dart

import 'package:equatable/equatable.dart';

class GameStatus extends Equatable {

  const GameStatus({
    required this.id,
    required this.checksum,
    required this.status,
    this.description,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String status;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props =>
      [id, checksum, status, description, createdAt, updatedAt];
}
