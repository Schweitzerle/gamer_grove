// ===== SEARCH MODEL =====
// lib/data/models/search/search_model.dart
import '../../../domain/entities/search/search.dart';

class SearchModel extends Search {
  const SearchModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.alternativeName,
    super.description,
    super.publishedAt,
    super.characterId,
    super.collectionId,
    super.companyId,
    super.gameId,
    super.platformId,
    super.themeId,
    super.testDummyId,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      alternativeName: json['alternative_name'],
      description: json['description'],
      publishedAt: _parseDateTime(json['published_at']),
      characterId: json['character'],
      collectionId: json['collection'],
      companyId: json['company'],
      gameId: json['game'],
      platformId: json['platform'],
      themeId: json['theme'],
      testDummyId: json['test_dummy'],
    );
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'name': name,
      'alternative_name': alternativeName,
      'description': description,
      'published_at': publishedAt?.millisecondsSinceEpoch,
      'character': characterId,
      'collection': collectionId,
      'company': companyId,
      'game': gameId,
      'platform': platformId,
      'theme': themeId,
      'test_dummy': testDummyId,
    };
  }

  // Factory method for creating search results from different entity types
  factory SearchModel.fromGame({
    required int id,
    required String checksum,
    required String name,
    required int gameId,
    String? alternativeName,
    String? description,
    DateTime? publishedAt,
  }) {
    return SearchModel(
      id: id,
      checksum: checksum,
      name: name,
      alternativeName: alternativeName,
      description: description,
      publishedAt: publishedAt,
      gameId: gameId,
    );
  }

  factory SearchModel.fromCompany({
    required int id,
    required String checksum,
    required String name,
    required int companyId,
    String? alternativeName,
    String? description,
    DateTime? publishedAt,
  }) {
    return SearchModel(
      id: id,
      checksum: checksum,
      name: name,
      alternativeName: alternativeName,
      description: description,
      publishedAt: publishedAt,
      companyId: companyId,
    );
  }

  factory SearchModel.fromPlatform({
    required int id,
    required String checksum,
    required String name,
    required int platformId,
    String? alternativeName,
    String? description,
    DateTime? publishedAt,
  }) {
    return SearchModel(
      id: id,
      checksum: checksum,
      name: name,
      alternativeName: alternativeName,
      description: description,
      publishedAt: publishedAt,
      platformId: platformId,
    );
  }

  factory SearchModel.fromCharacter({
    required int id,
    required String checksum,
    required String name,
    required int characterId,
    String? alternativeName,
    String? description,
    DateTime? publishedAt,
  }) {
    return SearchModel(
      id: id,
      checksum: checksum,
      name: name,
      alternativeName: alternativeName,
      description: description,
      publishedAt: publishedAt,
      characterId: characterId,
    );
  }

  factory SearchModel.fromCollection({
    required int id,
    required String checksum,
    required String name,
    required int collectionId,
    String? alternativeName,
    String? description,
    DateTime? publishedAt,
  }) {
    return SearchModel(
      id: id,
      checksum: checksum,
      name: name,
      alternativeName: alternativeName,
      description: description,
      publishedAt: publishedAt,
      collectionId: collectionId,
    );
  }

  factory SearchModel.fromTheme({
    required int id,
    required String checksum,
    required String name,
    required int themeId,
    String? alternativeName,
    String? description,
    DateTime? publishedAt,
  }) {
    return SearchModel(
      id: id,
      checksum: checksum,
      name: name,
      alternativeName: alternativeName,
      description: description,
      publishedAt: publishedAt,
      themeId: themeId,
    );
  }
}

