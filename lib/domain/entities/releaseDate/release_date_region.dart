// ===== RELEASE DATE REGION ENTITY =====
// lib/domain/entities/release_date/release_date_region.dart
import 'package:equatable/equatable.dart';

class ReleaseDateRegion extends Equatable {

  const ReleaseDateRegion({
    required this.id,
    required this.checksum,
    required this.region,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String region;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Helper getters
  bool get isEurope => region.toLowerCase().contains('europe');
  bool get isNorthAmerica => region.toLowerCase().contains('north america') ||
      region.toLowerCase().contains('usa') ||
      region.toLowerCase().contains('us');
  bool get isAsia => region.toLowerCase().contains('asia');
  bool get isJapan => region.toLowerCase().contains('japan');
  bool get isWorldwide => region.toLowerCase().contains('worldwide') ||
      region.toLowerCase().contains('global');

  String get displayName => region;

  @override
  List<Object?> get props => [
    id,
    checksum,
    region,
    createdAt,
    updatedAt,
  ];
}

