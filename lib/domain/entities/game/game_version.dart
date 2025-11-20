// ===== GAME VERSION ENTITY =====
// File: lib/domain/entities/game/game_version_model.dart

import 'package:equatable/equatable.dart';

class GameVersion extends Equatable {

  const GameVersion({
    required this.id,
    required this.checksum,
    this.gameId,
    this.featureIds = const [],
    this.gameIds = const [],
    this.url,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final int? gameId;
  final List<int> featureIds;
  final List<int> gameIds;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, checksum, gameId, featureIds, gameIds, url, createdAt, updatedAt];
}
