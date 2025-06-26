// lib/data/models/multiplayer_mode_model.dart
import '../../domain/entities/multiplayer_mode.dart';

class MultiplayerModeModel extends MultiplayerMode {
  const MultiplayerModeModel({
    required super.id,
    super.campaignCoop,
    super.dropin,
    super.lancoop,
    super.offlineCoop,
    super.offlineCoopMax,
    super.offlineMax,
    super.onlineCoop,
    super.onlineCoopMax,
    super.onlineMax,
    super.splitscreen,
    super.splitscreenOnline,
  });

  factory MultiplayerModeModel.fromJson(Map<String, dynamic> json) {
    return MultiplayerModeModel(
      id: json['id'] ?? 0,
      campaignCoop: json['campaigncoop'] ?? false,
      dropin: json['dropin'] ?? false,
      lancoop: json['lancoop'] ?? false,
      offlineCoop: json['offlinecoop'] ?? false,
      offlineCoopMax: json['offlinecoopmax'] ?? false,
      offlineMax: json['offlinemax'] ?? false,
      onlineCoop: json['onlinecoop'] ?? false,
      onlineCoopMax: json['onlinecoopmax'] ?? false,
      onlineMax: json['onlinemax'] ?? false,
      splitscreen: json['splitscreen'] ?? false,
      splitscreenOnline: json['splitscreenonline'] ?? false,
    );
  }
}