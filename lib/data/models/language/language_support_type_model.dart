// lib/data/models/language_support_type_model.dart
import 'package:gamer_grove/domain/entities/language/language_support_type.dart';

class LanguageSupportTypeModel extends LanguageSupportType {
  const LanguageSupportTypeModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.createdAt,
    super.updatedAt,
  });

  factory LanguageSupportTypeModel.fromJson(Map<String, dynamic> json) {
    return LanguageSupportTypeModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
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
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Factory methods for common types
  static LanguageSupportTypeModel audio() => const LanguageSupportTypeModel(
    id: LanguageSupportTypes.audio,
    checksum: '',
    name: 'Audio',
  );

  static LanguageSupportTypeModel subtitles() => const LanguageSupportTypeModel(
    id: LanguageSupportTypes.subtitles,
    checksum: '',
    name: 'Subtitles',
  );

  static LanguageSupportTypeModel interface() => const LanguageSupportTypeModel(
    id: LanguageSupportTypes.interface,
    checksum: '',
    name: 'Interface',
  );

  static LanguageSupportTypeModel fullAudio() => const LanguageSupportTypeModel(
    id: LanguageSupportTypes.fullAudio,
    checksum: '',
    name: 'Full Audio',
  );
}