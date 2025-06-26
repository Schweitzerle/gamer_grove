// lib/domain/entities/player_perspective.dart
import 'package:equatable/equatable.dart';

class PlayerPerspective extends Equatable {
  final int id;
  final String name;
  final String slug;

  const PlayerPerspective({
    required this.id,
    required this.name,
    required this.slug,
  });

  @override
  List<Object> get props => [id, name, slug];
}
