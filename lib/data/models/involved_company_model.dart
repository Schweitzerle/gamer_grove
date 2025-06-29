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
    return InvolvedCompanyModel(
      id: json['id'] ?? 0,
      company: _parseCompany(json['company']),
      isDeveloper: json['developer'] ?? false,
      isPublisher: json['publisher'] ?? false,
      isPorting: json['porting'] ?? false,
      isSupporting: json['supporting'] ?? false,
    );
  }

  static Company _parseCompany(dynamic companyData) {
    if (companyData is Map<String, dynamic>) {
      return CompanyModel.fromJson(companyData);
    }
    // Fallback for simple company data
    return CompanyModel(
      id: companyData['id'] ?? 0,
      name: companyData['name'] ?? 'Unknown Company', checksum: companyData['checksum'] ?? 'N/A',
    );
  }
}