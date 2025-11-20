// lib/domain/entities/language.dart
import 'package:equatable/equatable.dart';

class Language extends Equatable {

  const Language({
    required this.id,
    required this.checksum,
    required this.locale,
    required this.name,
    this.nativeName,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String locale;       // e.g., "en-US", "de-DE"
  final String name;         // English name of the language
  final String? nativeName;  // Native name of the language
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Extract language code from locale (e.g., "en" from "en-US")
  String get languageCode => locale.split('-').first.toLowerCase();

  // Extract country code from locale (e.g., "US" from "en-US")
  String? get countryCode {
    final parts = locale.split('-');
    return parts.length > 1 ? parts[1].toUpperCase() : null;
  }

  // Get display name (prefer native name if available)
  String get displayName => nativeName ?? name;

  // Check if it's a major language
  bool get isMajorLanguage => [
    'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'ja', 'zh', 'ko',
  ].contains(languageCode);

  @override
  List<Object?> get props => [
    id,
    checksum,
    locale,
    name,
    nativeName,
    createdAt,
    updatedAt,
  ];
}

// Common language codes for quick reference
class LanguageCodes {
  static const String english = 'en';
  static const String spanish = 'es';
  static const String french = 'fr';
  static const String german = 'de';
  static const String italian = 'it';
  static const String portuguese = 'pt';
  static const String russian = 'ru';
  static const String japanese = 'ja';
  static const String chinese = 'zh';
  static const String korean = 'ko';
  static const String dutch = 'nl';
  static const String polish = 'pl';
  static const String swedish = 'sv';
  static const String norwegian = 'no';
  static const String danish = 'da';
  static const String finnish = 'fi';
  static const String arabic = 'ar';
  static const String turkish = 'tr';
  static const String czech = 'cs';
  static const String hungarian = 'hu';
}