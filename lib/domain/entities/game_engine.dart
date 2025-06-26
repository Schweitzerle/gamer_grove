// lib/domain/entities/game_engine.dart
import 'package:equatable/equatable.dart';

class GameEngine extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? url;

  const GameEngine({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.url,
  });

  @override
  List<Object?> get props => [id, name, description, logoUrl, url];
}