// ===== PLATFORM WEBSITE MODEL =====
// File: lib/data/models/platform/platform_website_model.dart

import '../../../domain/entities/platform/platform_website.dart';
import '../../../domain/entities/website/website_type.dart';
import '../website/website_type_model.dart';

class PlatformWebsiteModel extends PlatformWebsite {
  const PlatformWebsiteModel({
    required super.id,
    required super.checksum,
    required super.url,
    super.trusted,
    super.platformId,
    super.typeId,
    super.type,
    super.category,
  });

  factory PlatformWebsiteModel.fromJson(Map<String, dynamic> json) {
    return PlatformWebsiteModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      url: json['url'] ?? '',
      trusted: json['trusted'] ?? false,
      platformId: json['platform'],
      typeId: json['type'] is int ? json['type'] : null,
      type: _parseWebsiteType(json['type']),
      category: _parseCategory(json['category']),
    );
  }

  static WebsiteType? _parseWebsiteType(dynamic typeData) {
    if (typeData is Map<String, dynamic>) {
      return WebsiteTypeModel.fromJson(typeData);
    }
    return null;
  }

  static WebsiteCategory? _parseCategory(dynamic category) {
    if (category is int) {
      return WebsiteCategory.fromValue(category);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'url': url,
      'trusted': trusted,
      'platform': platformId,
      'type': typeId ?? type?.toJson(),
      'category': category?.value,
    };
  }

  // Helper factory for creating platform websites
  factory PlatformWebsiteModel.official(String url, {int? platformId}) {
    return PlatformWebsiteModel(
      id: 0,
      checksum: '',
      url: url,
      trusted: true,
      platformId: platformId,
      type: WebsiteTypeModel.fromCategory(WebsiteCategory.official),
    );
  }
}

// Extension to add toJson method to WebsiteType entity (if not already defined)
extension WebsiteTypeToJson on WebsiteType {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'type': type,
    };
  }
}