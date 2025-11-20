// lib/data/models/platform_family_model.dart
import 'package:gamer_grove/domain/entities/platform/platform_family.dart';

class PlatformFamilyModel extends PlatformFamily {
  const PlatformFamilyModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.slug,
  });

  factory PlatformFamilyModel.fromJson(Map<String, dynamic> json) {
    return PlatformFamilyModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'name': name,
      'slug': slug,
    };
  }
}