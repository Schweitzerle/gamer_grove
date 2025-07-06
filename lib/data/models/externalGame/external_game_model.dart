// lib/data/models/external_game_model.dart

import '../../../domain/entities/externalGame/external_game.dart';
import '../../../core/utils/json_helpers.dart';

class ExternalGameModel extends ExternalGame {
  const ExternalGameModel({
    required super.id,
    required super.checksum,
    required super.name,
    required super.uid,
    super.countries,
    super.externalGameSourceId,
    super.gameId,
    super.gameReleaseFormatId,
    super.platformId,
    super.url,
    super.year,
    super.createdAt,
    super.updatedAt,
    super.categoryEnum,
    super.mediaEnum,
  });

  factory ExternalGameModel.fromJson(Map<String, dynamic> json) {
    return ExternalGameModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      uid: json['uid'] ?? '',
      countries: _parseCountries(json['countries']),
      // Fixed: Handle both ID and expanded object
      externalGameSourceId: JsonHelpers.extractId(json['external_game_source']),
      gameId: JsonHelpers.extractId(json['game']),
      gameReleaseFormatId: JsonHelpers.extractId(json['game_release_format']),
      platformId: JsonHelpers.extractId(json['platform']),
      url: json['url'],
      year: json['year'],
      createdAt: JsonHelpers.parseDateTime(json['created_at']),
      updatedAt: JsonHelpers.parseDateTime(json['updated_at']),
      categoryEnum: _parseCategoryEnum(json['category']),
      mediaEnum: _parseMediaEnum(json['media']),
    );
  }

  static List<int> _parseCountries(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is int)
          .map((item) => item as int)
          .toList();
    }
    return [];
  }

  static ExternalGameCategoryEnum? _parseCategoryEnum(dynamic category) {
    if (category is int) {
      return ExternalGameCategoryEnum.fromValue(category);
    }
    return null;
  }

  static ExternalGameMediaEnum? _parseMediaEnum(dynamic media) {
    if (media is int) {
      return ExternalGameMediaEnum.fromValue(media);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'countries': countries,
      'external_game_source': externalGameSourceId,
      'game': gameId,
      'game_release_format': gameReleaseFormatId,
      'name': name,
      'platform': platformId,
      'uid': uid,
      'url': url,
      'year': year,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': categoryEnum?.value,
      'media': mediaEnum?.value,
    };
  }

  // Helper methods to extract expanded data if available

  /// Get platform name from expanded data (if available)
  String? get platformName {
    // This would be available if you store the expanded object
    // For now, just return null since we only store the ID
    return null;
  }

  /// Get external game source name from expanded data (if available)
  String? get sourceName {
    // This would be available if you store the expanded object
    // For now, just return null since we only store the ID
    return null;
  }

  /// Get game release format name from expanded data (if available)
  String? get formatName {
    // This would be available if you store the expanded object
    // For now, just return null since we only store the ID
    return null;
  }

  /// Alternative constructor that can handle expanded objects and store them
  factory ExternalGameModel.fromJsonWithExpanded(Map<String, dynamic> json) {
    return ExternalGameModelExpanded.fromJson(json);
  }
}

/// Extended version that can store expanded reference data
class ExternalGameModelExpanded extends ExternalGameModel {
  final String? platformName;
  final String? sourceName;
  final String? formatName;

  const ExternalGameModelExpanded({
    required super.id,
    required super.checksum,
    required super.name,
    required super.uid,
    super.countries,
    super.externalGameSourceId,
    super.gameId,
    super.gameReleaseFormatId,
    super.platformId,
    super.url,
    super.year,
    super.createdAt,
    super.updatedAt,
    super.categoryEnum,
    super.mediaEnum,
    this.platformName,
    this.sourceName,
    this.formatName,
  });

  factory ExternalGameModelExpanded.fromJson(Map<String, dynamic> json) {
    return ExternalGameModelExpanded(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      uid: json['uid'] ?? '',
      countries: ExternalGameModel._parseCountries(json['countries']),
      externalGameSourceId: JsonHelpers.extractId(json['external_game_source']),
      gameId: JsonHelpers.extractId(json['game']),
      gameReleaseFormatId: JsonHelpers.extractId(json['game_release_format']),
      platformId: JsonHelpers.extractId(json['platform']),
      url: json['url'],
      year: json['year'],
      createdAt: JsonHelpers.parseDateTime(json['created_at']),
      updatedAt: JsonHelpers.parseDateTime(json['updated_at']),
      categoryEnum: ExternalGameModel._parseCategoryEnum(json['category']),
      mediaEnum: ExternalGameModel._parseMediaEnum(json['media']),
      // Extract expanded data
      platformName: JsonHelpers.extractNested<String>(json, 'platform.name'),
      sourceName: JsonHelpers.extractNested<String>(json, 'external_game_source.name'),
      formatName: JsonHelpers.extractNested<String>(json, 'game_release_format.format'),
    );
  }
}