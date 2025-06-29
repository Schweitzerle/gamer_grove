// lib/data/models/date_format_model.dart

import '../../../domain/entities/date/date_format.dart';

class DateFormatModel extends DateFormat {
  const DateFormatModel({
    required super.id,
    required super.checksum,
    required super.format,
    super.createdAt,
    super.updatedAt,
  });

  factory DateFormatModel.fromJson(Map<String, dynamic> json) {
    return DateFormatModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      format: json['format'] ?? 'TBD',
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
      'format': format,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper factory for creating from category enum (legacy support)
  factory DateFormatModel.fromCategory(DateFormatCategory category) {
    return DateFormatModel(
      id: category.value,
      checksum: '',
      format: category.format,
    );
  }
}