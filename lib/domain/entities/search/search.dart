// ===== SEARCH ENTITY =====
// lib/domain/entities/search/search.dart
import 'package:equatable/equatable.dart';

enum SearchResultType {
  game,
  character,
  collection,
  company,
  platform,
  theme,
  unknown,
}

class Search extends Equatable {
  final int id;
  final String checksum;
  final String? alternativeName;
  final String name;
  final String? description;
  final DateTime? publishedAt;

  // Reference IDs to actual entities
  final int? characterId;
  final int? collectionId;
  final int? companyId;
  final int? gameId;
  final int? platformId;
  final int? themeId;
  final int? testDummyId; // Usually not relevant for production

  const Search({
    required this.id,
    required this.checksum,
    required this.name,
    this.alternativeName,
    this.description,
    this.publishedAt,
    this.characterId,
    this.collectionId,
    this.companyId,
    this.gameId,
    this.platformId,
    this.themeId,
    this.testDummyId,
  });

  // Helper getters for determining result type
  SearchResultType get resultType {
    if (gameId != null) return SearchResultType.game;
    if (characterId != null) return SearchResultType.character;
    if (collectionId != null) return SearchResultType.collection;
    if (companyId != null) return SearchResultType.company;
    if (platformId != null) return SearchResultType.platform;
    if (themeId != null) return SearchResultType.theme;
    return SearchResultType.unknown;
  }

  int? get entityId {
    switch (resultType) {
      case SearchResultType.game: return gameId;
      case SearchResultType.character: return characterId;
      case SearchResultType.collection: return collectionId;
      case SearchResultType.company: return companyId;
      case SearchResultType.platform: return platformId;
      case SearchResultType.theme: return themeId;
      default: return null;
    }
  }

  String get entityType {
    switch (resultType) {
      case SearchResultType.game: return 'Game';
      case SearchResultType.character: return 'Character';
      case SearchResultType.collection: return 'Collection';
      case SearchResultType.company: return 'Company';
      case SearchResultType.platform: return 'Platform';
      case SearchResultType.theme: return 'Theme';
      default: return 'Unknown';
    }
  }

  // Helper getters
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasAlternativeName => alternativeName != null && alternativeName!.isNotEmpty;
  bool get hasPublishedDate => publishedAt != null;
  bool get isGameResult => resultType == SearchResultType.game;
  bool get isCharacterResult => resultType == SearchResultType.character;
  bool get isCollectionResult => resultType == SearchResultType.collection;
  bool get isCompanyResult => resultType == SearchResultType.company;
  bool get isPlatformResult => resultType == SearchResultType.platform;
  bool get isThemeResult => resultType == SearchResultType.theme;

  String get displayName => name;
  String get displayDescription => description ?? '';
  String get displayAlternativeName => alternativeName ?? '';

  @override
  List<Object?> get props => [
    id,
    checksum,
    alternativeName,
    name,
    description,
    publishedAt,
    characterId,
    collectionId,
    companyId,
    gameId,
    platformId,
    themeId,
    testDummyId,
  ];
}

