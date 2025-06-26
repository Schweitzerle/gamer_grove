// lib/data/models/keyword_model.dart
import '../../domain/entities/keyword.dart';

class KeywordModel extends Keyword {
  const KeywordModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory KeywordModel.fromJson(Map<String, dynamic> json) {
    return KeywordModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      slug: json['slug'] ?? json['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? 'unknown',
    );
  }
}