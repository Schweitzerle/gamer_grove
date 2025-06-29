// ===== RELEASE DATE MODEL (UPDATED TO IGDB API SPEC) =====
// lib/data/models/release_date/release_date_model.dart
import '../../../domain/entities/releaseDate/release_date.dart';

class ReleaseDateModel extends ReleaseDate {
  const ReleaseDateModel({
    required super.id,
    required super.checksum,
    super.createdAt,
    super.updatedAt,
    super.date,
    super.human,
    super.month,
    super.year,
    super.gameId,
    super.platformId,
    super.dateFormatId,
    super.releaseRegionId,
    super.statusId,
    super.categoryEnum,
    super.regionEnum,
  });

  factory ReleaseDateModel.fromJson(Map<String, dynamic> json) {
    return ReleaseDateModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      date: _parseDateTime(json['date']),
      human: json['human'],
      month: json['m'],
      year: json['y'],
      gameId: json['game'],
      platformId: json['platform'],
      dateFormatId: json['date_format'],
      releaseRegionId: json['release_region'],
      statusId: json['status'],
      categoryEnum: _parseCategoryEnum(json['category']),
      regionEnum: _parseRegionEnum(json['region']),
    );
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  static ReleaseDateCategory? _parseCategoryEnum(dynamic category) {
    if (category is int) {
      return ReleaseDateCategory.fromValue(category);
    }
    return null;
  }

  static ReleaseDateRegionEnum? _parseRegionEnum(dynamic region) {
    if (region is int) {
      return ReleaseDateRegionEnum.fromValue(region);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'date': date?.toIso8601String(),
      'human': human,
      'm': month,
      'y': year,
      'game': gameId,
      'platform': platformId,
      'date_format': dateFormatId,
      'release_region': releaseRegionId,
      'status': statusId,
      'category': categoryEnum?.value,
      'region': regionEnum?.value,
    };
  }

  // Factory method for creating from simple date
  factory ReleaseDateModel.fromSimpleDate({
    required int id,
    required String checksum,
    required DateTime date,
    String? human,
    int? gameId,
    int? platformId,
    ReleaseDateRegionEnum? region,
  }) {
    return ReleaseDateModel(
      id: id,
      checksum: checksum,
      date: date,
      human: human,
      month: date.month,
      year: date.year,
      gameId: gameId,
      platformId: platformId,
      categoryEnum: ReleaseDateCategory.yyyymmdd,
      regionEnum: region ?? ReleaseDateRegionEnum.unknown,
    );
  }

  // Factory method for creating from year only
  factory ReleaseDateModel.fromYear({
    required int id,
    required String checksum,
    required int year,
    String? human,
    int? gameId,
    int? platformId,
    ReleaseDateRegionEnum? region,
  }) {
    return ReleaseDateModel(
      id: id,
      checksum: checksum,
      year: year,
      human: human,
      gameId: gameId,
      platformId: platformId,
      categoryEnum: ReleaseDateCategory.yyyy,
      regionEnum: region ?? ReleaseDateRegionEnum.unknown,
    );
  }

  // Factory method for creating quarterly release
  factory ReleaseDateModel.fromQuarter({
    required int id,
    required String checksum,
    required int year,
    required int quarter, // 1-4
    String? human,
    int? gameId,
    int? platformId,
    ReleaseDateRegionEnum? region,
  }) {
    ReleaseDateCategory category;
    switch (quarter) {
      case 1: category = ReleaseDateCategory.yyyyq1; break;
      case 2: category = ReleaseDateCategory.yyyyq2; break;
      case 3: category = ReleaseDateCategory.yyyyq3; break;
      case 4: category = ReleaseDateCategory.yyyyq4; break;
      default: category = ReleaseDateCategory.yyyy;
    }

    return ReleaseDateModel(
      id: id,
      checksum: checksum,
      year: year,
      human: human ?? 'Q$quarter $year',
      gameId: gameId,
      platformId: platformId,
      categoryEnum: category,
      regionEnum: region ?? ReleaseDateRegionEnum.unknown,
    );
  }

  // Factory method for TBD release
  factory ReleaseDateModel.tbd({
    required int id,
    required String checksum,
    int? gameId,
    int? platformId,
    ReleaseDateRegionEnum? region,
  }) {
    return ReleaseDateModel(
      id: id,
      checksum: checksum,
      human: 'TBD',
      gameId: gameId,
      platformId: platformId,
      categoryEnum: ReleaseDateCategory.tbd,
      regionEnum: region ?? ReleaseDateRegionEnum.unknown,
    );
  }
}

