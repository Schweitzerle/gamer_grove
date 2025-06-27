// lib/domain/entities/game_engine.dart
import 'package:equatable/equatable.dart';

class GameEngine extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final String? description;
  final int? logoId;
  final String? slug;
  final String? url;
  final List<int> companyIds;
  final List<int> platformIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GameEngine({
    required this.id,
    required this.checksum,
    required this.name,
    this.description,
    this.logoId,
    this.slug,
    this.url,
    this.companyIds = const [],
    this.platformIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasLogo => logoId != null;
  bool get hasCompanies => companyIds.isNotEmpty;
  bool get hasPlatforms => platformIds.isNotEmpty;
  bool get hasUrl => url != null && url!.isNotEmpty;

  int get companyCount => companyIds.length;
  int get platformCount => platformIds.length;

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
    slug,
    url,
    companyIds,
    platformIds,
    createdAt,
    updatedAt,
  ];
}