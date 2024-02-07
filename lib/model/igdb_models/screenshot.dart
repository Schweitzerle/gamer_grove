import 'package:gamer_grove/model/igdb_models/game_video.dart';

import 'game.dart';

class Screenshot {
  int id;
  bool? alphaChannel;
  bool? animated;
  String? checksum;
  Game? game;
  int? height;
  String? imageId;
  String? url;
  int? width;

  Screenshot({
    required this.id,
    this.alphaChannel,
    this.animated,
    this.checksum,
    this.game,
    this.height,
    this.imageId,
    this.url,
    this.width,
  });

  factory Screenshot.fromJson(Map<String, dynamic> json) {
    String? screenshotUrl = json["url"];
    if (screenshotUrl != null) {
      screenshotUrl = screenshotUrl.replaceFirst("t_thumb", "t_720p");
    }
    return Screenshot(
      alphaChannel: json['alpha_channel'],
      animated: json['animated'],
      checksum: json['checksum'],
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'])
          : Game.fromJson(json['game']))
          : null,
      height: json['height'],
      imageId: json['image_id'],
      url: 'https:$screenshotUrl',
      width: json['width'], id: json['id'],
    );
  }
}
