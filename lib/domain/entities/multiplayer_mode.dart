// lib/domain/entities/multiplayer_mode.dart
import 'package:equatable/equatable.dart';

class MultiplayerMode extends Equatable {
  final int id;
  final bool campaignCoop;
  final bool dropin;
  final bool lancoop;
  final bool offlineCoop;
  final bool offlineCoopMax;
  final bool offlineMax;
  final bool onlineCoop;
  final bool onlineCoopMax;
  final bool onlineMax;
  final bool splitscreen;
  final bool splitscreenOnline;

  const MultiplayerMode({
    required this.id,
    this.campaignCoop = false,
    this.dropin = false,
    this.lancoop = false,
    this.offlineCoop = false,
    this.offlineCoopMax = false,
    this.offlineMax = false,
    this.onlineCoop = false,
    this.onlineCoopMax = false,
    this.onlineMax = false,
    this.splitscreen = false,
    this.splitscreenOnline = false,
  });

  @override
  List<Object> get props => [
    id, campaignCoop, dropin, lancoop, offlineCoop, offlineCoopMax,
    offlineMax, onlineCoop, onlineCoopMax, onlineMax, splitscreen, splitscreenOnline
  ];
}