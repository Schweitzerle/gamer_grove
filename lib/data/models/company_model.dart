// lib/data/models/company_model.dart
import '../../domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.name,
    super.description,
    super.logoUrl,
    super.country,
    super.website,
    super.foundedDate,
    super.aliases,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Company',
      description: json['description'],
      logoUrl: _parseLogoUrl(json['logo']),
      country: json['country']?.toString(),
      website: json['url'],
      foundedDate: _parseDate(json['start_date']),
      aliases: _parseAliases(json['alternative_names']),
    );
  }

  static String? _parseLogoUrl(dynamic logo) {
    if (logo is Map && logo['url'] != null) {
      return 'https:${logo['url']}';
    }
    return null;
  }

  static DateTime? _parseDate(dynamic date) {
    if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  static List<String> _parseAliases(dynamic aliases) {
    if (aliases is List) {
      return aliases
          .where((alias) => alias is Map && alias['name'] != null)
          .map((alias) => alias['name'].toString())
          .toList();
    }
    return [];
  }
}