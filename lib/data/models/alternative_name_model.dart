// lib/data/models/alternative_name_model.dart
import 'package:gamer_grove/domain/entities/alternative_name.dart';

class AlternativeNameModel extends AlternativeName {
  const AlternativeNameModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.comment,
    super.gameId,
    super.createdAt,
    super.updatedAt,
  });

  factory AlternativeNameModel.fromJson(Map<String, dynamic> json) {
    return AlternativeNameModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      comment: json['comment'],
      gameId: json['game'],
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
      'comment': comment,
      'game': gameId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}