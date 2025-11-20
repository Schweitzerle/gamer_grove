// ===== GAME VERSION FEATURE ENTITY =====
// File: lib/domain/entities/game/game_version_feature.dart

import 'package:equatable/equatable.dart';

class GameVersionFeature extends Equatable {

  const GameVersionFeature({
    required this.id,
    required this.checksum,
    required this.title,
    this.description,
    this.category,
    this.position,
    this.valueIds = const [],
  });
  final int id;
  final String checksum;
  final String title;
  final String? description;
  final String? category; // boolean, description
  final int? position;
  final List<int> valueIds;

  bool get isBoolean => category == 'boolean';
  bool get isDescription => category == 'description';

  @override
  List<Object?> get props => [id, checksum, title, description, category, position, valueIds];
}

// Category Enum
enum GameVersionFeatureCategory {
  boolean('boolean'),
  description('description');

  const GameVersionFeatureCategory(this.value);
  final String value;

  static GameVersionFeatureCategory fromValue(String value) {
    return values.firstWhere((cat) => cat.value == value, orElse: () => description);
  }
}
