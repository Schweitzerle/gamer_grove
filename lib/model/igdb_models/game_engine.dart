import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/igdb_models/company_logo.dart';
import 'package:gamer_grove/model/igdb_models/game_engine_logo.dart';
import 'package:gamer_grove/model/igdb_models/platform.dart';

class GameEngine {
  int id;
  final String? checksum;
  final List<Company>? companies;
  final int? createdAt;
  final String? description;
  final GameEngineLogo? logo;
  final String? name;
  final List<PlatformIGDB>? platforms;
  final String? slug;
  final int? updatedAt;
  final String? url;

  GameEngine({
    required this.id,
    this.checksum,
    this.companies,
    this.createdAt,
    this.description,
    this.logo,
    this.name,
    this.platforms,
    this.slug,
    this.updatedAt,
    this.url,
  });

  factory GameEngine.fromJson(Map<String, dynamic> json) {
    return GameEngine(
      checksum: json['checksum'],
      companies: json['companies'] != null
          ? List<Company>.from(
        json['companies'].map((companies) {
          if (companies is int) {
            return Company(id: companies);
          } else {
            return Company.fromJson(companies);
          }
        }),
      )
          : null,
      createdAt: json['created_at'],
      description: json['description'],
      logo: json['logo'] != null
          ? (json['logo'] is int
          ? GameEngineLogo(id: json['logo'])
          : GameEngineLogo.fromJson(json['logo']))
          : null,
      name: json['name'],
      platforms: json['platforms'] != null
          ? List<PlatformIGDB>.from(
        json['platforms'].map((companies) {
          if (companies is int) {
            return PlatformIGDB(id: companies);
          } else {
            return PlatformIGDB.fromJson(companies);
          }
        }),
      )
          : null,
      slug: json['slug'],
      updatedAt: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }
}
