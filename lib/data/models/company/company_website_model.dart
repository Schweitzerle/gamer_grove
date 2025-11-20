
// ===== COMPANY WEBSITE MODEL =====
// lib/data/models/company/company_website_model.dart
import 'package:gamer_grove/domain/entities/company/company_website.dart';

class CompanyWebsiteModel extends CompanyWebsite {
  const CompanyWebsiteModel({
    required super.id,
    required super.checksum,
    required super.url,
    super.trusted = false,
    super.category = CompanyWebsiteCategory.unknown,
    super.typeId,
  });

  factory CompanyWebsiteModel.fromJson(Map<String, dynamic> json) {
    return CompanyWebsiteModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      url: json['url'] ?? '',
      trusted: json['trusted'] ?? false,
      category: _parseCategory(json['category']),
      typeId: json['type'],
    );
  }

  static CompanyWebsiteCategory _parseCategory(dynamic category) {
    if (category is int) {
      return CompanyWebsiteCategory.fromValue(category);
    }
    return CompanyWebsiteCategory.unknown;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'url': url,
      'trusted': trusted,
      'category': category.value,
      'type': typeId,
    };
  }
}