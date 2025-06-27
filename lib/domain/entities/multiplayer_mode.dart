// lib/domain/entities/multiplayer_mode.dart
import 'package:equatable/equatable.dart';

class MultiplayerMode extends Equatable {
  final int id;
  final bool campaignCoop;
  final bool dropin;
  final bool lancoop;
  final bool offlineCoop;
  final int offlineCoopMax;
  final int offlineMax;
  final bool onlineCoop;
  final int onlineCoopMax;
  final int onlineMax;
  final bool splitscreen;
  final bool splitscreenOnline;

  const MultiplayerMode({
    required this.id,
    this.campaignCoop = false,
    this.dropin = false,
    this.lancoop = false,
    this.offlineCoop = false,
    this.offlineCoopMax = 0,
    this.offlineMax = 0,
    this.onlineCoop = false,
    this.onlineCoopMax = 0,
    this.onlineMax = 0,
    this.splitscreen = false,
    this.splitscreenOnline = false,
  });

  @override
  List<Object> get props => [
    id, campaignCoop, dropin, lancoop, offlineCoop, offlineCoopMax,
    offlineMax, onlineCoop, onlineCoopMax, onlineMax, splitscreen, splitscreenOnline
  ];
}