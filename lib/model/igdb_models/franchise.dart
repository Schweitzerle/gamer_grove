import 'game.dart';

class Franchise {
  int id;
  final String? checksum;
  final int? createdAt;
  final List<Game>? games;
  final String? name;
  final String? slug;
  final int? updatedAt;
  final String? url;

  Franchise({
    required this.id,
    this.checksum,
    this.createdAt,
    this.games,
    this.name,
    this.slug,
    this.updatedAt,
    this.url,
  });

  factory Franchise.fromJson(Map<String, dynamic> json) {
    return Franchise(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      games: json['games'] != null
          ? List<Game>.from(
        json['games'].map((game) {
          if (game is int) {
            return Game(id: game);
          } else {
            return Game.fromJson(game);
          }
        }),
      )
          : null,
      name: json['name'],
      slug: json['slug'],
      updatedAt: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }
}
