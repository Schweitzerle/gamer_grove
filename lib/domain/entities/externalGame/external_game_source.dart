// lib/domain/entities/external_game_source.dart
import 'package:equatable/equatable.dart';

class ExternalGameSource extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExternalGameSource({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, checksum, name, createdAt, updatedAt];
}