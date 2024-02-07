import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/language.dart';
import 'package:gamer_grove/model/igdb_models/language_support_type.dart';

class LanguageSupport {
  int id;
  final String? checksum;
  final int? createdAt;
  final Game? game; // Hier kann der Datentyp je nach Bedarf angepasst werden
  final Language? language; // Hier kann der Datentyp je nach Bedarf angepasst werden
  final LanguageSupportType? languageSupportType; // Hier kann der Datentyp je nach Bedarf angepasst werden
  final int? updatedAt;

  LanguageSupport({
    required this.id,
    this.checksum,
    this.createdAt,
    this.game,
    this.language,
    this.languageSupportType,
    this.updatedAt,
  });

  factory LanguageSupport.fromJson(Map<String, dynamic> json) {
    return LanguageSupport(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'])
          : Game.fromJson(json['game']))
          : null,
      language: json['language'] != null
          ? (json['language'] is int
          ? Language(id: json['language'])
          : Language.fromJson(json['language']))
          : null,
      languageSupportType: json['language_support_type'] != null
          ? (json['language_support_type'] is int
          ? LanguageSupportType(id: json['language_support_type'])
          : LanguageSupportType.fromJson(json['language_support_type']))
          : null,
      updatedAt: json['updated_at'], id: json['id'],
    );
  }
}
