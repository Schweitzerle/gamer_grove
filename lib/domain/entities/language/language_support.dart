// lib/domain/entities/language_support.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/language/language.dart';
import 'package:gamer_grove/domain/entities/language/language_support_type.dart';

class LanguageSupport extends Equatable {

  const LanguageSupport({
    required this.id,
    required this.checksum,
    this.gameId,
    this.languageId,
    this.languageSupportTypeId,
    this.language,
    this.supportType,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final int? gameId;
  final int? languageId;
  final int? languageSupportTypeId;
  final Language? language;
  final LanguageSupportType? supportType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Helper getters
  String get languageName => language?.displayName ?? 'Unknown';
  String get supportTypeName => supportType?.name ?? 'Unknown';

  // Check support level
  bool get hasAudioSupport => supportType?.isAudio ?? false;
  bool get hasSubtitles => supportType?.isSubtitles ?? false;
  bool get hasInterfaceSupport => supportType?.isInterface ?? false;
  bool get hasFullSupport => supportType?.isFullAudio ?? false;

  @override
  List<Object?> get props => [
    id,
    checksum,
    gameId,
    languageId,
    languageSupportTypeId,
    language,
    supportType,
    createdAt,
    updatedAt,
  ];
}