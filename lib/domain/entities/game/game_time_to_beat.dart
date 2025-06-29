// ===== GAME TIME TO BEAT ENTITY =====
// File: lib/domain/entities/game/game_time_to_beat.dart

import 'package:equatable/equatable.dart';

class GameTimeToBeat extends Equatable {
  final int id;
  final String checksum;
  final int? gameId;
  final int? hastily;      // Rushed playthrough time in seconds
  final int? normally;     // Normal playthrough time in seconds
  final int? completely;   // Completionist time in seconds
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GameTimeToBeat({
    required this.id,
    required this.checksum,
    this.gameId,
    this.hastily,
    this.normally,
    this.completely,
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters for hours
  double? get hastilyHours => hastily != null ? hastily! / 3600 : null;
  double? get normallyHours => normally != null ? normally! / 3600 : null;
  double? get completelyHours => completely != null ? completely! / 3600 : null;

  // Format time as string (e.g., "12.5 hours")
  String? get hastilyFormatted => hastilyHours != null ? '${hastilyHours!.toStringAsFixed(1)} hours' : null;
  String? get normallyFormatted => normallyHours != null ? '${normallyHours!.toStringAsFixed(1)} hours' : null;
  String? get completelyFormatted => completelyHours != null ? '${completelyHours!.toStringAsFixed(1)} hours' : null;

  @override
  List<Object?> get props => [id, checksum, gameId, hastily, normally, completely, createdAt, updatedAt];
}


