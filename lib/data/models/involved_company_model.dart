// lib/data/models/involved_company_model.dart
import '../../domain/entities/involved_company.dart';
import '../../domain/entities/company/company.dart';
import 'company/company_model.dart';

class InvolvedCompanyModel extends InvolvedCompany {
  const InvolvedCompanyModel({
    required super.id,
    required super.company,
    super.isDeveloper,
    super.isPublisher,
    super.isPorting,
    super.isSupporting,
  });

  factory InvolvedCompanyModel.fromJson(Map<String, dynamic> json) {
    try {
      return InvolvedCompanyModel(
        id: _parseInt(json['id']) ?? 0,
        company: _parseCompany(json['company']),
        isDeveloper: _parseBool(json['developer']),
        isPublisher: _parseBool(json['publisher']),
        isPorting: _parseBool(json['porting']),
        isSupporting: _parseBool(json['supporting']),
      );
    } catch (e) {
      rethrow;
    }
  }

  // === SAFE PARSING HELPERS ===
  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static Company _parseCompany(dynamic companyData) {
    // FIX: Handle null company data
    if (companyData == null) {
      return _createFallbackCompany();
    }

    // Parse full company object
    if (companyData is Map<String, dynamic>) {
      try {
        return CompanyModel.fromJson(companyData);
      } catch (e) {
        return _createFallbackCompany();
      }
    }

    // Handle simple ID reference
    if (companyData is int) {
      return CompanyModel(
        id: companyData,
        name: 'Company #$companyData',
        checksum: '',
      );
    }

    // Fallback for unexpected data
    return _createFallbackCompany();
  }

  // Helper to create a fallback company when data is missing/invalid
  static Company _createFallbackCompany() {
    return const CompanyModel(
      id: 0,
      name: 'Unknown Company',
      checksum: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': {
        'id': company.id,
        'name': company.name,
        'checksum': company.checksum,
      },
      'developer': isDeveloper,
      'publisher': isPublisher,
      'porting': isPorting,
      'supporting': isSupporting,
    };
  }
}
