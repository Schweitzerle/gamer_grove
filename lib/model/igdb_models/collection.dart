import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';
import 'game.dart';

class Collection {
  int id;
  final List<int>? asChildRelations;
  final List<int>? asParentRelations;
  final String? checksum;
  final DateTime? createdAt;
  final List<Game>? games;
  final String? name;
  final String? slug;
  final int? type;
  final DateTime? updatedAt;
  final String? url;

  Collection({
    required this.id,
    this.asChildRelations,
    this.asParentRelations,
    this.checksum,
    this.createdAt,
    this.games,
    this.name,
    this.slug,
    this.type,
    this.updatedAt,
    this.url,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      asChildRelations: json['as_child_relations'] != null
          ? List<int>.from(json['as_child_relations'])
          : null,
      asParentRelations: json['as_parent_relations'] != null
          ? List<int>.from(json['as_parent_relations'])
          : null,
      checksum: json['checksum'],
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
          : null,
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
      type: json['type'],
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] * 1000)
          : null,
      url: json['url'], id: json['id'],
    );
  }
}
