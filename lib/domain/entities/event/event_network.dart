// ===== EVENT NETWORK ENTITY =====
// lib/domain/entities/event/event_network.dart
import 'package:equatable/equatable.dart';

class EventNetwork extends Equatable {
  final int id;
  final String checksum;
  final String url;
  final int? eventId;
  final int? networkTypeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventNetwork({
    required this.id,
    required this.checksum,
    required this.url,
    this.eventId,
    this.networkTypeId,
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  bool get isAssociatedWithEvent => eventId != null;
  bool get hasNetworkType => networkTypeId != null;
  bool get isValidUrl => url.isNotEmpty && Uri.tryParse(url) != null;

  // URL type detection helpers
  bool get isTwitchUrl => url.toLowerCase().contains('twitch.tv');
  bool get isYouTubeUrl => url.toLowerCase().contains('youtube.com') ||
      url.toLowerCase().contains('youtu.be');
  bool get isTwitterUrl => url.toLowerCase().contains('twitter.com') ||
      url.toLowerCase().contains('x.com');
  bool get isFacebookUrl => url.toLowerCase().contains('facebook.com');
  bool get isInstagramUrl => url.toLowerCase().contains('instagram.com');
  bool get isDiscordUrl => url.toLowerCase().contains('discord.gg') ||
      url.toLowerCase().contains('discord.com');

  bool get isSocialMediaUrl => isTwitterUrl || isFacebookUrl ||
      isInstagramUrl || isDiscordUrl;
  bool get isStreamingUrl => isTwitchUrl || isYouTubeUrl;

  // Extract platform name from URL
  String get platformName {
    if (isTwitchUrl) return 'Twitch';
    if (isYouTubeUrl) return 'YouTube';
    if (isTwitterUrl) return 'Twitter/X';
    if (isFacebookUrl) return 'Facebook';
    if (isInstagramUrl) return 'Instagram';
    if (isDiscordUrl) return 'Discord';

    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [
    id,
    checksum,
    url,
    eventId,
    networkTypeId,
    createdAt,
    updatedAt,
  ];
}