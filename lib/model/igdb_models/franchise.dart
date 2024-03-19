import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';
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
        json['games'].map((dlc) {
          if (dlc is int) {
            return Game(id: dlc, gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0));
          } else {
            return Game.fromJson(dlc, IGDBApiService.getGameModel(dlc['id']));
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
