// lib/data/models/franchise_model.dart
import 'package:gamer_grove/core/utils/json_helpers.dart';

import '../../domain/entities/franchise.dart';

class FranchiseModel extends Franchise {
  const FranchiseModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.slug,
    super.url,
    super.gameIds = const [],
    super.createdAt,
    super.updatedAt,
    super.games
  });

  factory FranchiseModel.fromJson(Map<String, dynamic> json) {
    return FranchiseModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      url: json['url'],
      gameIds: _parseIdList(json['games']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      games: JsonHelpers.extractGameList(json['games'])
    );
  }

  static List<int> _parseIdList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is int || (item is Map && item['id'] is int))
          .map((item) => item is int ? item : item['id'] as int)
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'name': name,
      'slug': slug,
      'url': url,
      'games': gameIds,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}