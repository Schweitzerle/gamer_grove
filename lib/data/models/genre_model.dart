// ===== GENRE MODEL =====
// lib/data/models/genre_model.dart
import '../../domain/entities/genre.dart';

class GenreModel extends Genre {
  const GenreModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? json['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }

  /// Erstellt ein Mock-Genre für Tests
  factory GenreModel.mock({
    int id = 1,
    String name = 'Action',
    String? slug,
  }) {
    return GenreModel(
      id: id,
      name: name,
      slug: slug ?? name.toLowerCase().replaceAll(' ', '-'),
    );
  }
}

extension GenreListExtensions on List<Genre> {
  /// Findet ein Genre anhand der ID
  Genre? findById(int id) {
    try {
      return firstWhere((genre) => genre.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Findet ein Genre anhand des Namens
  Genre? findByName(String name) {
    try {
      return firstWhere((genre) => genre.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Gibt alle Genre-Namen als String-Liste zurück
  List<String> get names => map((genre) => genre.name).toList();

  /// Filtert Genres nach einer Liste von IDs
  List<Genre> whereIdIn(List<int> ids) {
    return where((genre) => ids.contains(genre.id)).toList();
  }
}



