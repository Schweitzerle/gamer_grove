// ==================================================
// ENHANCED GAME ENGINE ENTITY (WITH FULL OBJECTS)
// ==================================================

// lib/domain/entities/game/game_engine.dart
import 'package:equatable/equatable.dart';
import 'game_engine_logo.dart';
import '../company/company.dart';
import '../platform/platform.dart';

class GameEngine extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final String? description;
  final int? logoId;
  final GameEngineLogo? logo; // ✅ NEU: Logo-Objekt hinzugefügt
  final String? slug;
  final String? url;

  // Legacy ID fields (for backward compatibility)
  final List<int> companyIds;
  final List<int> platformIds;

  // ✅ NEU: Vollständige Objekte
  final List<Company> companies;
  final List<Platform> platforms;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GameEngine({
    required this.id,
    required this.checksum,
    required this.name,
    this.description,
    this.logoId,
    this.logo, // ✅ NEU
    this.slug,
    this.url,
    this.companyIds = const [],
    this.platformIds = const [],
    this.companies = const [], // ✅ NEU
    this.platforms = const [], // ✅ NEU
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasLogo => logo != null || logoId != null;
  bool get hasCompanies => companies.isNotEmpty;
  bool get hasPlatforms => platforms.isNotEmpty;
  bool get hasUrl => url != null && url!.isNotEmpty;

  int get companyCount => companies.length;
  int get platformCount => platforms.length;

  // ✅ NEU: Logo URL getters
  String? get logoUrl => logo?.logoMedUrl;
  String? get logoThumbUrl => logo?.thumbUrl;
  String? get logoMed2xUrl => logo?.logoMed2xUrl;

  // Check if this is a popular engine (used by many companies/platforms)
  bool get isPopularEngine => companyCount >= 3 || platformCount >= 5;
  bool get isWidelySupported => platformIds.length >= 8;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    description,
    logoId,
    logo,
    slug,
    url,
    companyIds,
    platformIds,
    companies,
    platforms,
    createdAt,
    updatedAt,
  ];
}


