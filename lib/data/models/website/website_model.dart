// ===========================================
// ERWEITERTE WEBSITEMODEL MIT TOJSON
// ===========================================
// lib/data/models/website/website_model.dart
import 'package:gamer_grove/data/models/website/website_type_model.dart';
import 'package:gamer_grove/domain/entities/website/website.dart';
import 'package:gamer_grove/domain/entities/website/website_type.dart';

class WebsiteModel extends Website {
  const WebsiteModel({
    required super.id,
    required super.url,
    required super.type,
    super.title,
  });

  factory WebsiteModel.fromUrl(String url, WebsiteType type,
      {int? id,}) {
    return WebsiteModel(
      id: id ?? 0,
      url: url,
      type: type,
    );
  }

  factory WebsiteModel.fromJson(Map<String, dynamic> json) {
    return WebsiteModel(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      type: _parseType(json['type']),
    );
  }

  static WebsiteType _parseType(dynamic typeData) {
    if (typeData is Map<String, dynamic>) {
      // Expanded type object from API
      return WebsiteTypeModel.fromJson(typeData);
    } else if (typeData is int) {
      // Legacy: category ID - convert to WebsiteType using the enum
      final category = WebsiteCategory.fromValue(typeData);
      return WebsiteTypeModel.fromCategory(category);
    } else {
      // Fallback: unknown type
      return const WebsiteTypeModel(
        id: 0,
        checksum: '',
        type: 'unknown',
      );
    }
  }

  // *** NEUE TOJSON METHODE ***
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type,
      'title': title,
    };
  }
}
