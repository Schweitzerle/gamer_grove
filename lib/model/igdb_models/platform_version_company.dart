import 'package:gamer_grove/model/igdb_models/company.dart';

class PlatformVersionCompany {
  int id;
  final String? checksum;
  final String? comment;
  final Company? companyId;
  final bool? isDeveloper;
  final bool? isManufacturer;

  PlatformVersionCompany({
    required this.id,
    this.checksum,
    this.comment,
    this.companyId,
    this.isDeveloper,
    this.isManufacturer,
  });

  factory PlatformVersionCompany.fromJson(Map<String, dynamic> json) {
    return PlatformVersionCompany(
      checksum: json['checksum'],
      comment: json['comment'],
      companyId: json['company'] != null
          ? (json['company'] is int
          ? Company(id: json['company'])
          : Company.fromJson(json['company']))
          : null,
      isDeveloper: json['developer'],
      isManufacturer: json['manufacturer'], id: json['id'],
    );
  }
}
