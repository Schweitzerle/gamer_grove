// lib/domain/entities/language_support.dart
import 'package:equatable/equatable.dart';

enum LanguageSupportType {
  voice,
  subtitles,
  interface,
  unknown,
}

class LanguageSupport extends Equatable {
  final int id;
  final String languageCode; // ISO 639-1
  final String languageName;
  final LanguageSupportType supportType;

  const LanguageSupport({
    required this.id,
    required this.languageCode,
    required this.languageName,
    required this.supportType,
  });

  @override
  List<Object> get props => [id, languageCode, languageName, supportType];
}