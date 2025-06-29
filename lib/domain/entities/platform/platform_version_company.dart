// ===== PLATFORM VERSION COMPANY ENTITY =====
// File: lib/domain/entities/platform/platform_version_company.dart

import 'package:equatable/equatable.dart';

class PlatformVersionCompany extends Equatable {
  final int id;
  final String checksum;
  final String? comment;
  final int? companyId;
  final bool developer;
  final bool manufacturer;

  const PlatformVersionCompany({
    required this.id,
    required this.checksum,
    this.comment,
    this.companyId,
    this.developer = false,
    this.manufacturer = false,
  });

  bool get isDeveloper => developer;
  bool get isManufacturer => manufacturer;

  String get roleDescription {
    if (developer && manufacturer) return 'Developer & Manufacturer';
    if (developer) return 'Developer';
    if (manufacturer) return 'Manufacturer';
    return 'Unknown Role';
  }

  @override
  List<Object?> get props => [
    id,
    checksum,
    comment,
    companyId,
    developer,
    manufacturer,
  ];
}
