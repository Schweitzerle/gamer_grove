import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/platform.dart';

class MultiplayerMode {
  int id;
  final bool? campaignCoop;
  final String? checksum;
  final bool? dropin;
  final Game? game;
  final bool? lanCoop;
  final bool? offlineCoop;
  final int? offlineCoopMax;
  final int? offlineMax;
  final bool? onlineCoop;
  final int? onlineCoopMax;
  final int? onlineMax;
  final PlatformIGDB? platform;
  final bool? splitScreen;
  final bool? splitScreenOnline;

  MultiplayerMode({
    required this.id,
    this.campaignCoop,
    this.checksum,
    this.dropin,
    this.game,
    this.lanCoop,
    this.offlineCoop,
    this.offlineCoopMax,
    this.offlineMax,
    this.onlineCoop,
    this.onlineCoopMax,
    this.onlineMax,
    this.platform,
    this.splitScreen,
    this.splitScreenOnline,
  });

  factory MultiplayerMode.fromJson(Map<String, dynamic> json) {
    return MultiplayerMode(
      campaignCoop: json['campaigncoop'],
      checksum: json['checksum'],
      dropin: json['dropin'],
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'])
          : Game.fromJson(json['game']))
          : null,
      lanCoop: json['lancoop'],
      offlineCoop: json['offlinecoop'],
      offlineCoopMax: json['offlinecoopmax'],
      offlineMax: json['offlinemax'],
      onlineCoop: json['onlinecoop'],
      onlineCoopMax: json['onlinecoopmax'],
      onlineMax: json['onlinemax'],
      platform: json['platform'] != null
          ? (json['platform'] is int
          ? PlatformIGDB(id: json['platform'])
          : PlatformIGDB.fromJson(json['platform']))
          : null,
      splitScreen: json['splitscreen'],
      splitScreenOnline: json['splitscreenonline'], id: json['id'],
    );
  }
}
