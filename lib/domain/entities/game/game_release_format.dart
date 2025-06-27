// lib/domain/entities/game_release_format.dart
import 'package:equatable/equatable.dart';

class GameReleaseFormat extends Equatable {
  final int id;
  final String checksum;
  final String format;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GameReleaseFormat({
    required this.id,
    required this.checksum,
    required this.format,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, checksum, format, createdAt, updatedAt];
}