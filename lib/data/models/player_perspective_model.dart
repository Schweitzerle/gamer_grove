// lib/data/models/player_perspective_model.dart
import '../../domain/entities/player_perspective.dart';

class PlayerPerspectiveModel extends PlayerPerspective {
  const PlayerPerspectiveModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory PlayerPerspectiveModel.fromJson(Map<String, dynamic> json) {
    return PlayerPerspectiveModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Perspective',
      slug: json['slug'] ?? json['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? 'unknown',
    );
  }
}