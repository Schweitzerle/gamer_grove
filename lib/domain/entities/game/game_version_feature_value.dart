// ===== GAME VERSION FEATURE VALUE ENTITY =====
// File: lib/domain/entities/game/game_version_feature_value.dart

import 'package:equatable/equatable.dart';

class GameVersionFeatureValue extends Equatable {
  final int id;
  final String checksum;
  final int? gameId;
  final int? gameFeatureId;
  final String? includedFeature; // NO, YES, UNKNOWN
  final String? note;

  const GameVersionFeatureValue({
    required this.id,
    required this.checksum,
    this.gameId,
    this.gameFeatureId,
    this.includedFeature,
    this.note,
  });

  bool get isIncluded => includedFeature == 'YES';
  bool get isExcluded => includedFeature == 'NO';
  bool get isUnknown => includedFeature == 'UNKNOWN' || includedFeature == null;

  @override
  List<Object?> get props => [id, checksum, gameId, gameFeatureId, includedFeature, note];
}

// Included Feature Enum
enum IncludedFeature {
  no('NO'),
  yes('YES'),
  unknown('UNKNOWN');

  const IncludedFeature(this.value);
  final String value;

  static IncludedFeature fromValue(String? value) {
    if (value == null) return unknown;
    return values.firstWhere((feature) => feature.value == value, orElse: () => unknown);
  }
}