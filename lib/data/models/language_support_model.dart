// lib/data/models/language_support_model.dart
import '../../domain/entities/language_support.dart';

class LanguageSupportModel extends LanguageSupport {
  const LanguageSupportModel({
    required super.id,
    required super.languageCode,
    required super.languageName,
    required super.supportType,
  });

  factory LanguageSupportModel.fromJson(Map<String, dynamic> json) {
    return LanguageSupportModel(
      id: json['id'] ?? 0,
      languageCode: json['language'] ?? 'unknown',
      languageName: _getLanguageName(json['language']),
      supportType: _parseSupportType(json['language_support_type']),
    );
  }

  static String _getLanguageName(dynamic languageCode) {
    if (languageCode is! String) return 'Unknown';

    // ISO 639-1 language codes to names
    final languageMap = {
      'en': 'English',
      'de': 'German',
      'fr': 'French',
      'es': 'Spanish',
      'it': 'Italian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'ru': 'Russian',
      'pt': 'Portuguese',
      'nl': 'Dutch',
      'pl': 'Polish',
      'sv': 'Swedish',
      'no': 'Norwegian',
      'da': 'Danish',
      'fi': 'Finnish',
      'ar': 'Arabic',
      'he': 'Hebrew',
      'tr': 'Turkish',
      'th': 'Thai',
      'vi': 'Vietnamese',
      'cs': 'Czech',
      'hu': 'Hungarian',
      'ro': 'Romanian',
      'bg': 'Bulgarian',
      'hr': 'Croatian',
      'sk': 'Slovak',
      'sl': 'Slovenian',
      'et': 'Estonian',
      'lv': 'Latvian',
      'lt': 'Lithuanian',
      'uk': 'Ukrainian',
    };

    return languageMap[languageCode] ?? languageCode.toUpperCase();
  }

  static LanguageSupportType _parseSupportType(dynamic supportType) {
    if (supportType is int) {
      switch (supportType) {
        case 1: return LanguageSupportType.voice;
        case 2: return LanguageSupportType.subtitles;
        case 3: return LanguageSupportType.interface;
        default: return LanguageSupportType.unknown;
      }
    }
    return LanguageSupportType.unknown;
  }
}