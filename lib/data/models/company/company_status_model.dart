// ===== COMPANY STATUS MODEL =====
// lib/data/models/company/company_status_model.dart
import 'package:gamer_grove/domain/entities/company/company_status.dart';

class CompanyStatusModel extends CompanyStatus {
  const CompanyStatusModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.createdAt,
    super.updatedAt,
  });

  factory CompanyStatusModel.fromJson(Map<String, dynamic> json) {
    return CompanyStatusModel(
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
}
