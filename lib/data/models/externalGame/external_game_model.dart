// lib/data/models/external_game_model.dart

import '../../../domain/entities/externalGame/external_game.dart';

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
      externalGameSourceId: json['external_game_source'],
      gameId: json['game'],
      gameReleaseFormatId: json['game_release_format'],
      platformId: json['platform'],
      url: json['url'],
      year: json['year'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
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

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
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
}