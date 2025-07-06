// lib/data/models/game_engine_model.dart
import '../../../domain/entities/game/game_engine.dart';

class GameEngineModel extends GameEngine {
  const GameEngineModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.description,
    super.logoId,
    super.slug,
    super.url,
    super.companyIds = const [],
    super.platformIds = const [],
    super.createdAt,
    super.updatedAt,
  });

  factory GameEngineModel.fromJson(Map<String, dynamic> json) {
    try {
      return GameEngineModel(
        id: _parseInt(json['id']) ?? 0,
        checksum: _parseString(json['checksum']) ?? '',
        name: _parseString(json['name']) ?? '',
        description: _parseString(json['description']),
        // FIX: Handle logo as either ID or full object
        logoId: _parseReferenceId(json['logo']),
        slug: _parseString(json['slug']),
        url: _parseString(json['url']),
        companyIds: _parseIdList(json['companies']),
        platformIds: _parseIdList(json['platforms']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
      );
    } catch (e, stackTrace) {
      print('❌ GameEngineModel.fromJson failed: $e');
      print('📄 JSON data: $json');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // === SAFE PARSING HELPERS ===
  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  // NEW: Helper method to extract ID from either int or object
  static int? _parseReferenceId(dynamic data) {
    if (data is int) {
      return data;
    } else if (data is Map && data['id'] is int) {
      return data['id'];
    }
    return null;
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
    if (date is String && date.isNotEmpty) {
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
      'description': description,
      'logo': logoId,
      'slug': slug,
      'url': url,
      'companies': companyIds,
      'platforms': platformIds,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}