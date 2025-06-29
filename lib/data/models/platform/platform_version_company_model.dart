// ===== PLATFORM VERSION COMPANY MODEL =====
// File: lib/data/models/platform/platform_version_company_model.dart

import '../../../domain/entities/platform/platform_version_company.dart';

class PlatformVersionCompanyModel extends PlatformVersionCompany {
  const PlatformVersionCompanyModel({
    required super.id,
    required super.checksum,
    super.comment,
    super.companyId,
    super.developer,
    super.manufacturer,
  });

  factory PlatformVersionCompanyModel.fromJson(Map<String, dynamic> json) {
    return PlatformVersionCompanyModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      comment: json['comment'],
      companyId: json['company'],
      developer: json['developer'] ?? false,
      manufacturer: json['manufacturer'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'comment': comment,
      'company': companyId,
      'developer': developer,
      'manufacturer': manufacturer,
    };
  }
}
