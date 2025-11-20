// ==================================================
// ENHANCED GAME ENGINE MODEL (WITH FULL PARSING)
// ==================================================

import 'package:gamer_grove/data/models/company/company_model.dart';
import 'package:gamer_grove/data/models/game/game_engine_logo_model.dart';
import 'package:gamer_grove/data/models/platform/platform_model.dart';
import 'package:gamer_grove/domain/entities/company/company.dart';
// lib/data/models/game/game_engine_model.dart
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import 'package:gamer_grove/domain/entities/game/game_engine_logo.dart';
import 'package:gamer_grove/domain/entities/platform/platform.dart';

class GameEngineModel extends GameEngine {
  const GameEngineModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.description,
    super.logoId,
    super.logo,
    super.slug,
    super.url,
    super.companyIds = const [],
    super.platformIds = const [],
    super.companies = const [],
    super.platforms = const [],
    super.createdAt,
    super.updatedAt,
  });

  factory GameEngineModel.fromJson(Map<String, dynamic> json) {
    try {
      // ✅ PARSE GAME ENGINE LOGO OBJECT
      GameEngineLogo? logo;
      if (json['logo'] != null) {
        if (json['logo'] is Map<String, dynamic>) {
          try {
            logo = GameEngineLogoModel.fromJson(json['logo']);
          } catch (e) {}
        }
      }

      // ✅ PARSE COMPANIES OBJECTS
      final companies = <Company>[];
      if (json['companies'] is List) {
        for (final companyData in json['companies']) {
          if (companyData is Map<String, dynamic>) {
            try {
              final company = CompanyModel.fromJson(companyData);
              companies.add(company);
            } catch (e) {}
          }
        }
      }

      // ✅ PARSE PLATFORMS OBJECTS
      final platforms = <Platform>[];
      if (json['platforms'] is List) {
        for (final platformData in json['platforms']) {
          if (platformData is Map<String, dynamic>) {
            try {
              final platform = PlatformModel.fromJson(platformData);
              platforms.add(platform);
            } catch (e) {}
          }
        }
      }

      return GameEngineModel(
        id: _parseInt(json['id']) ?? 0,
        checksum: _parseString(json['checksum']) ?? '',
        name: _parseString(json['name']) ?? '',
        description: _parseString(json['description']),
        logoId: _parseReferenceId(json['logo']),
        logo: logo, // ✅ NEU: Logo-Objekt hinzugefügt
        slug: _parseString(json['slug']),
        url: _parseString(json['url']),
        companyIds: _parseIdList(json['companies']),
        platformIds: _parseIdList(json['platforms']),
        companies: companies, // ✅ NEU: Vollständige Company-Objekte
        platforms: platforms, // ✅ NEU: Vollständige Platform-Objekte
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ✅ SAFE PARSING HELPERS
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

  // ✅ Helper method to extract ID from either int or object
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
