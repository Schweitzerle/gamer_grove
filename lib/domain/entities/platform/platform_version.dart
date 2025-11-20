// ===== PLATFORM VERSION ENTITY =====
// File: lib/domain/entities/platform/platform_version.dart

import 'package:equatable/equatable.dart';

class PlatformVersion extends Equatable {

  const PlatformVersion({
    required this.id,
    required this.checksum,
    required this.name,
    this.connectivity,
    this.cpu,
    this.graphics,
    this.mainManufacturerId,
    this.media,
    this.memory,
    this.os,
    this.output,
    this.platformLogoId,
    this.platformVersionReleaseDateIds = const [],
    this.resolutions,
    this.slug,
    this.sound,
    this.storage,
    this.summary,
    this.url,
    this.companyIds = const [],
  });
  final int id;
  final String checksum;
  final String? connectivity;
  final String? cpu;
  final String? graphics;
  final int? mainManufacturerId;
  final String? media;
  final String? memory;
  final String name;
  final String? os;
  final String? output;
  final int? platformLogoId;
  final List<int> platformVersionReleaseDateIds;
  final String? resolutions;
  final String? slug;
  final String? sound;
  final String? storage;
  final String? summary;
  final String? url;
  final List<int> companyIds;

  // Helper to check if it's a revision/slim model
  bool get isRevision => name.toLowerCase().contains('slim') ||
      name.toLowerCase().contains('pro') ||
      name.toLowerCase().contains('lite') ||
      name.toLowerCase().contains('revision');

  @override
  List<Object?> get props => [
    id,
    checksum,
    connectivity,
    cpu,
    graphics,
    mainManufacturerId,
    media,
    memory,
    name,
    os,
    output,
    platformLogoId,
    platformVersionReleaseDateIds,
    resolutions,
    slug,
    sound,
    storage,
    summary,
    url,
    companyIds,
  ];
}


