// ===== POPULARITY PRIMITIVE MODEL =====
// lib/data/models/popularity/popularity_primitive_model.dart
import '../../../domain/entities/popularity/popularity_primitive.dart';

class PopularityPrimitiveModel extends PopularityPrimitive {
  const PopularityPrimitiveModel({
    required super.id,
    required super.checksum,
    required super.gameId,
    required super.value,
    super.createdAt,
    super.updatedAt,
    super.calculatedAt,
    super.popularityTypeId,
    super.externalPopularitySourceId,
    super.popularitySourceEnum,
  });

  factory PopularityPrimitiveModel.fromJson(Map<String, dynamic> json) {
    return PopularityPrimitiveModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      gameId: json['game_id'] ?? 0,
      value: _parseDouble(json['value']) ?? 0.0,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      calculatedAt: _parseDateTime(json['calculated_at']),
      popularityTypeId: json['popularity_type'],
      externalPopularitySourceId: json['external_popularity_source'],
      popularitySourceEnum: _parsePopularitySourceEnum(json['popularity_source']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  static PopularitySourceEnum? _parsePopularitySourceEnum(dynamic source) {
    if (source is int) {
      return PopularitySourceEnum.fromValue(source);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'game_id': gameId,
      'value': value,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'calculated_at': calculatedAt?.toIso8601String(),
      'popularity_type': popularityTypeId,
      'external_popularity_source': externalPopularitySourceId,
      'popularity_source': popularitySourceEnum?.value,
    };
  }

  // Factory method for creating from simple values
  factory PopularityPrimitiveModel.create({
    required int id,
    required String checksum,
    required int gameId,
    required double value,
    PopularitySourceEnum? source,
    int? popularityTypeId,
    DateTime? calculatedAt,
  }) {
    return PopularityPrimitiveModel(
      id: id,
      checksum: checksum,
      gameId: gameId,
      value: value,
      popularitySourceEnum: source,
      popularityTypeId: popularityTypeId,
      calculatedAt: calculatedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  // Factory method for Steam popularity
  factory PopularityPrimitiveModel.steam({
    required int id,
    required String checksum,
    required int gameId,
    required double value,
    int? popularityTypeId,
  }) {
    return PopularityPrimitiveModel.create(
      id: id,
      checksum: checksum,
      gameId: gameId,
      value: value,
      source: PopularitySourceEnum.steam,
      popularityTypeId: popularityTypeId,
    );
  }

  // Factory method for IGDB popularity
  factory PopularityPrimitiveModel.igdb({
    required int id,
    required String checksum,
    required int gameId,
    required double value,
    int? popularityTypeId,
  }) {
    return PopularityPrimitiveModel.create(
      id: id,
      checksum: checksum,
      gameId: gameId,
      value: value,
      source: PopularitySourceEnum.igdb,
      popularityTypeId: popularityTypeId,
    );
  }
}

