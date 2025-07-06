// ===== COMPANY MODEL (UPDATED WITH LOGO SUPPORT) =====
// lib/data/models/company/company_model.dart
import '../../../../domain/entities/company/company.dart';
import '../../../../domain/entities/company/company_logo.dart';
import 'company_model_logo.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.description,
    super.slug,
    super.url,
    super.country,
    super.createdAt,
    super.updatedAt,
    super.changeDate,
    super.changeDateCategory,
    super.changeDateFormatId,
    super.changedCompanyId,
    super.parentId,
    super.logoId,
    super.logo, // NEU
    super.statusId,
    super.startDate,
    super.startDateCategory,
    super.startDateFormatId,
    super.developedGameIds,
    super.publishedGameIds,
    super.websiteIds,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      slug: json['slug'],
      url: json['url'],
      country: json['country'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      changeDate: _parseDateTime(json['change_date']),
      changeDateCategory: _parseChangeDateCategory(json['change_date_category']),
      changeDateFormatId: json['change_date_format'],
      changedCompanyId: json['changed_company_id'],
      parentId: json['parent'],
      logoId: _parseLogoId(json['logo']),
      logo: _parseLogo(json['logo']), // NEU: Parse logo object
      statusId: json['status'],
      startDate: _parseDateTime(json['start_date']),
      startDateCategory: _parseChangeDateCategory(json['start_date_category']),
      startDateFormatId: json['start_date_format'],
      developedGameIds: _parseIdList(json['developed']),
      publishedGameIds: _parseIdList(json['published']),
      websiteIds: _parseIdList(json['websites']),
    );
  }

  // NEU: Parse logo data
  static int? _parseLogoId(dynamic logoData) {
    if (logoData is int) {
      return logoData;
    } else if (logoData is Map<String, dynamic>) {
      return logoData['id'];
    }
    return null;
  }

  // NEU: Parse logo object
  static CompanyLogo? _parseLogo(dynamic logoData) {
    if (logoData is Map<String, dynamic>) {
      try {
        return CompanyLogoModel.fromJson(logoData);
      } catch (e) {
        print('Error parsing company logo: $e');
        return null;
      }
    }
    return null;
  }

  static List<int> _parseIdList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is int || (item is Map && item['id'] is int))
          .map((item) => item is int ? item : item['id'] as int)
          .toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  static CompanyChangeDateCategory? _parseChangeDateCategory(dynamic category) {
    if (category is int) {
      return CompanyChangeDateCategory.fromValue(category);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'name': name,
      'description': description,
      'slug': slug,
      'url': url,
      'country': country,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'change_date': changeDate?.toIso8601String(),
      'change_date_category': changeDateCategory?.value,
      'change_date_format': changeDateFormatId,
      'changed_company_id': changedCompanyId,
      'parent': parentId,
      'logo': logoId,
      'status': statusId,
      'start_date': startDate?.toIso8601String(),
      'start_date_category': startDateCategory?.value,
      'start_date_format': startDateFormatId,
      'developed': developedGameIds,
      'published': publishedGameIds,
      'websites': websiteIds,
    };
  }
}