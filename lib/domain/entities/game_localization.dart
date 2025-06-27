// ===== GAME LOCALIZATION ENTITY =====
// lib/domain/entities/game_localization.dart
import 'package:equatable/equatable.dart';

enum LocalizationRegion {
  europe,
  northAmerica,
  australia,
  newZealand,
  japan,
  china,
  asia,
  worldwide,
  korea,
  brazil,
  unknown,
}

class GameLocalization extends Equatable {
  final int id;
  final String name;
  final LocalizationRegion region;

  const GameLocalization({
    required this.id,
    required this.name,
    this.region = LocalizationRegion.unknown,
  });

  @override
  List<Object?> get props => [id, name, region];
}