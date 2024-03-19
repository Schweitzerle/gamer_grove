import 'package:gamer_grove/model/igdb_models/event_logo.dart';
import 'package:gamer_grove/model/igdb_models/event_networkj.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/game_video.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';

class Event {
  final int id;
  final String? checksum;
  final int? createdAt;
  final String? description;
  final int? endTime;
  final EventLogo? eventLogo;
  final List<EventNetwork>? eventNetworks;
  final List<Game>? games;
  final String? liveStreamUrl;
  final String? name;
  final String? slug;
  final int? startTime;
  final String? timeZone;
  final int? updatedAt;
  final List<GameVideo>? videos;

  Event({
    required this.id,
    this.checksum,
    this.createdAt,
    this.description,
    this.endTime,
    this.eventLogo,
    this.eventNetworks,
    this.games,
    this.liveStreamUrl,
    this.name,
    this.slug,
    this.startTime,
    this.timeZone,
    this.updatedAt,
    this.videos,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      checksum: json['checksum'],
      createdAt: json['created_at'],
      description: json['description'],
      endTime: json['end_time'],
      eventLogo: json['event_logo'] != null
          ? (json['event_logo'] is int
          ? EventLogo(id: json['event_logo'])
          : EventLogo.fromJson(json['event_logo']))
          : null,

      eventNetworks: json['event_networks'] != null
          ? List<EventNetwork>.from(
        json['event_networks'].map((eventNetwork) {
          if (eventNetwork is int) {
            return EventNetwork(id: eventNetwork);
          } else {
            return EventNetwork.fromJson(eventNetwork);
          }
        }),
      )
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
      liveStreamUrl: json['live_stream_url'],
      name: json['name'],
      slug: json['slug'],
      startTime: json['start_time'],
      timeZone: json['time_zone'],
      updatedAt: json['updated_at'],
      videos: json['videos'] != null
          ? List<GameVideo>.from(
        json['videos'].map((video) {
          if (video is int) {
            return GameVideo(id: video);
          } else {
            return GameVideo.fromJson(video);
          }
        }),
      )
          : null,
    );
  }
}
