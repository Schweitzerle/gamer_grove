// domain/entities/game_mode.dart
import 'package:equatable/equatable.dart';

class GameMode extends Equatable {
  final int id;
  final String name;
  final String slug;

  const GameMode({
    required this.id,
    required this.name,
    required this.slug,
  });

  @override
  List<Object> get props => [id, name, slug];
}