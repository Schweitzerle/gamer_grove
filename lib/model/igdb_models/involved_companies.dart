import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';

class InvolvedCompany {
  int id;
  final String? checksum;
  final Company? company;
  final int? createdAt;
  final bool? developer;
  final Game? game;
  final bool? porting;
  final bool? publisher;
  final bool? supporting;
  final int? updatedAt;

  InvolvedCompany({
    required this.id,
    this.checksum,
    this.company,
    this.createdAt,
    this.developer,
    this.game,
    this.porting,
    this.publisher,
    this.supporting,
    this.updatedAt,
  });

  factory InvolvedCompany.fromJson(Map<String, dynamic> json) {
    return InvolvedCompany(
      checksum: json['checksum'],
      company: json['company'] != null
          ? (json['company'] is int
          ? Company(id: json['company'])
          : Company.fromJson(json['company']))
          : null,
      createdAt: json['created_at'],
      developer: json['developer'],
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'], gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0))
          : Game.fromJson(json['game'], IGDBApiService.getGameModel(json['game']['id'])))
          : null,
      porting: json['porting'],
      publisher: json['publisher'],
      supporting: json['supporting'],
      updatedAt: json['updated_at'], id: json['id'],
    );
  }
}
