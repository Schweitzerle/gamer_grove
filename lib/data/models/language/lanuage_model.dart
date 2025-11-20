// lib/data/models/language_model.dart
import 'package:gamer_grove/domain/entities/language/language.dart';

class LanguageModel extends Language {
  const LanguageModel({
    required super.id,
    required super.checksum,
    required super.locale,
    required super.name,
    super.nativeName,
    super.createdAt,
    super.updatedAt,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      locale: json['locale'] ?? '',
      name: json['name'] ?? '',
      nativeName: json['native_name'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'locale': locale,
      'name': name,
      'native_name': nativeName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Factory for creating common languages
  static LanguageModel english() => const LanguageModel(
    id: 1,
    checksum: '',
    locale: 'en-US',
    name: 'English',
    nativeName: 'English',
  );

  static LanguageModel german() => const LanguageModel(
    id: 2,
    checksum: '',
    locale: 'de-DE',
    name: 'German',
    nativeName: 'Deutsch',
  );

  static LanguageModel spanish() => const LanguageModel(
    id: 3,
    checksum: '',
    locale: 'es-ES',
    name: 'Spanish',
    nativeName: 'Español',
  );

  static LanguageModel french() => const LanguageModel(
    id: 4,
    checksum: '',
    locale: 'fr-FR',
    name: 'French',
    nativeName: 'Français',
  );

  static LanguageModel japanese() => const LanguageModel(
    id: 5,
    checksum: '',
    locale: 'ja-JP',
    name: 'Japanese',
    nativeName: '日本語',
  );
}