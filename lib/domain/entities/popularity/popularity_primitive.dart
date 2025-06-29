// ===== POPULARITY PRIMITIVE ENTITY =====
// lib/domain/entities/popularity/popularity_primitive.dart
import 'package:equatable/equatable.dart';

enum PopularitySourceEnum {
  steam(1),
  igdb(121),
  unknown(0);

  const PopularitySourceEnum(this.value);
  final int value;

  static PopularitySourceEnum fromValue(int value) {
    return values.firstWhere(
          (source) => source.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case steam: return 'Steam';
      case igdb: return 'IGDB';
      default: return 'Unknown';
    }
  }
}

class PopularityPrimitive extends Equatable {
  final int id;
  final String checksum;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? calculatedAt;

  // Game reference
  final int gameId;

  // Popularity data
  final double value; // The actual popularity value
  final int? popularityTypeId;
  final int? externalPopularitySourceId;

  // DEPRECATED but still useful
  final PopularitySourceEnum? popularitySourceEnum;

  const PopularityPrimitive({
    required this.id,
    required this.checksum,
    required this.gameId,
    required this.value,
    this.createdAt,
    this.updatedAt,
    this.calculatedAt,
    this.popularityTypeId,
    this.externalPopularitySourceId,
    this.popularitySourceEnum,
  });

  // Helper getters
  bool get hasPopularityType => popularityTypeId != null;
  bool get hasExternalSource => externalPopularitySourceId != null;
  bool get isCalculated => calculatedAt != null;
  bool get isFromSteam => popularitySourceEnum == PopularitySourceEnum.steam;
  bool get isFromIgdb => popularitySourceEnum == PopularitySourceEnum.igdb;

  // Value interpretation helpers
  bool get isHighPopularity => value >= 80.0;
  bool get isMediumPopularity => value >= 50.0 && value < 80.0;
  bool get isLowPopularity => value < 50.0;

  String get popularityLevel {
    if (isHighPopularity) return 'High';
    if (isMediumPopularity) return 'Medium';
    return 'Low';
  }

  String get sourceDisplayName {
    if (popularitySourceEnum != null) {
      return popularitySourceEnum!.displayName;
    }
    return 'Unknown Source';
  }

  // Time calculations
  Duration? get ageOfCalculation {
    if (calculatedAt == null) return null;
    return DateTime.now().difference(calculatedAt!);
  }

  bool get isStale {
    final age = ageOfCalculation;
    if (age == null) return true;
    // Consider popularity data stale after 7 days
    return age.inDays > 7;
  }

  bool get isFresh {
    final age = ageOfCalculation;
    if (age == null) return false;
    // Consider popularity data fresh within 24 hours
    return age.inHours <= 24;
  }

  @override
  List<Object?> get props => [
    id,
    checksum,
    createdAt,
    updatedAt,
    calculatedAt,
    gameId,
    value,
    popularityTypeId,
    externalPopularitySourceId,
    popularitySourceEnum,
  ];
}

