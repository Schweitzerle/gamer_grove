import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/game_localization.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';

class Cover {
  int id;
  final bool? alphaChannel;
  final bool? animated;
  final String? checksum;
  final Game? game;
  final GameLocalization? gameLocalization;
  final int? height;
  final String? imageId;
  final String? url;
  final int? width;

  Cover({
    required this.id,
    this.alphaChannel,
    this.animated,
    this.checksum,
    this.game,
    this.gameLocalization,
    this.height,
    this.imageId,
    this.url,
    this.width,
  });

  factory Cover.fromJson(Map<String, dynamic> json) {
    String? coverUrl = json["url"];
    if (coverUrl != null) {
      coverUrl = coverUrl.replaceFirst("t_thumb", "t_720p");
    }

    return Cover(
      alphaChannel: json['alpha_channel'],
      animated: json['animated'],
      checksum: json['checksum'],
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'], gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0))
          : Game.fromJson(json['game'], IGDBApiService.getGameModel(json['game']['id'])))
          : null,
      gameLocalization: json['game_localization'] != null
          ? (json['game_localization'] is int
          ? GameLocalization(id: json['game_localization'])
          : GameLocalization.fromJson(json['game_localization']))
          : null,
      height: json['height'],
      imageId: json['image_id'],
      url: 'https:$coverUrl', // Concatenate the modified URL
      width: json['width'],
      id: json['id'],
    );
  }
}