// ===== PLATFORM VERSION RELEASE DATE ENTITY =====
// File: lib/domain/entities/platform/platform_version_release_date.dart

import 'package:equatable/equatable.dart';
import '../date/date_format.dart';
import '../region.dart';

class PlatformVersionReleaseDate extends Equatable {
  final int id;
  final String checksum;
  final DateTime? date;
  final int? dateFormatId;
  final String? human;
  final int? month;
  final int? platformVersionId;
  final int? releaseRegionId;
  final int? year;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Legacy support
  final DateFormatCategory? category;
  final RegionEnum? region;

  const PlatformVersionReleaseDate({
    required this.id,
    required this.checksum,
    this.date,
    this.dateFormatId,
    this.human,
    this.month,
    this.platformVersionId,
    this.releaseRegionId,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.region,
  });

  bool get hasExactDate => dateFormatId == 0; // YYYYMMMMDD
  bool get isEstimate => dateFormatId != null && dateFormatId! > 2; // Quarter or TBD

  @override
  List<Object?> get props => [
    id,
    checksum,
    date,
    dateFormatId,
    human,
    month,
    platformVersionId,
    releaseRegionId,
    year,
    createdAt,
    updatedAt,
    category,
    region,
  ];
}

