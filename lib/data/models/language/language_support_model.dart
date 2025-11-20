// lib/data/models/language_support_model.dart
import 'package:gamer_grove/data/models/language/language_support_type_model.dart';
import 'package:gamer_grove/data/models/language/lanuage_model.dart';
import 'package:gamer_grove/domain/entities/language/language.dart';
import 'package:gamer_grove/domain/entities/language/language_support.dart';
import 'package:gamer_grove/domain/entities/language/language_support_type.dart';

class LanguageSupportModel extends LanguageSupport {
  const LanguageSupportModel({
    required super.id,
    required super.checksum,
    super.gameId,
    super.languageId,
    super.languageSupportTypeId,
    super.language,
    super.supportType,
    super.createdAt,
    super.updatedAt,
  });

  factory LanguageSupportModel.fromJson(Map<String, dynamic> json) {
    return LanguageSupportModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      gameId: json['game'],
      languageId: json['language'] is int ? json['language'] : null,
      languageSupportTypeId: json['language_support_type'] is int
          ? json['language_support_type']
          : null,
      language: _parseLanguage(json['language']),
      supportType: _parseSupportType(json['language_support_type']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static Language? _parseLanguage(dynamic languageData) {
    if (languageData is Map<String, dynamic>) {
      return LanguageModel.fromJson(languageData);
    }
    return null;
  }

  static LanguageSupportType? _parseSupportType(dynamic typeData) {
    if (typeData is Map<String, dynamic>) {
      return LanguageSupportTypeModel.fromJson(typeData);
    }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'game': gameId,
      'language': languageId ?? language?.toJson(),
      'language_support_type': languageSupportTypeId ?? supportType?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Extension to add toJson method to Language entity
extension LanguageToJson on Language {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'locale': locale,
      'name': name,
      'native_name': nativeName,
    };
  }
}

// Extension to add toJson method to LanguageSupportType entity
extension LanguageSupportTypeToJson on LanguageSupportType {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'name': name,
    };
  }
}