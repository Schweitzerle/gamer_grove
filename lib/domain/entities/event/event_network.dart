// ==================================================
// EVENT NETWORK ENTITY (ENHANCED)
// ==================================================

// lib/domain/entities/event/event_network.dart (ENHANCED)
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/domain/entities/event/network_type.dart';

class EventNetwork extends Equatable { // 🆕 Full NetworkType object instead of ID

  const EventNetwork({
    required this.id,
    required this.checksum,
    required this.url,
    this.eventId,
    this.networkTypeId,
    this.createdAt,
    this.updatedAt,
    this.networkType, // 🆕 Enhanced field
  });
  final int id;
  final String checksum;
  final String url;
  final int? eventId;
  final int? networkTypeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Enhanced field
  final NetworkType? networkType;

  // ==========================================
  // ENHANCED HELPER GETTERS
  // ==========================================

  bool get isAssociatedWithEvent => eventId != null;
  bool get hasNetworkType => networkType != null || networkTypeId != null;
  bool get hasNetworkTypeObject => networkType != null;
  bool get isValidUrl => url.isNotEmpty && Uri.tryParse(url) != null;

  // Enhanced URL type detection
  bool get isTwitchUrl => url.toLowerCase().contains('twitch.tv');
  bool get isYouTubeUrl => url.toLowerCase().contains('youtube.com') ||
      url.toLowerCase().contains('youtu.be');
  bool get isTwitterUrl => url.toLowerCase().contains('twitter.com') ||
      url.toLowerCase().contains('x.com');
  bool get isFacebookUrl => url.toLowerCase().contains('facebook.com');
  bool get isInstagramUrl => url.toLowerCase().contains('instagram.com');
  bool get isDiscordUrl => url.toLowerCase().contains('discord.gg') ||
      url.toLowerCase().contains('discord.com');
  bool get isTikTokUrl => url.toLowerCase().contains('tiktok.com');
  bool get isLinkedInUrl => url.toLowerCase().contains('linkedin.com');
  bool get isRedditUrl => url.toLowerCase().contains('reddit.com');

  bool get isSocialMediaUrl => isTwitterUrl || isFacebookUrl ||
      isInstagramUrl || isDiscordUrl || isTikTokUrl || isLinkedInUrl || isRedditUrl;
  bool get isStreamingUrl => isTwitchUrl || isYouTubeUrl;

  // Enhanced platform name detection
  String get platformName {
    if (networkType != null) return networkType!.name;

    if (isTwitchUrl) return 'Twitch';
    if (isYouTubeUrl) return 'YouTube';
    if (isTwitterUrl) return 'Twitter/X';
    if (isFacebookUrl) return 'Facebook';
    if (isInstagramUrl) return 'Instagram';
    if (isDiscordUrl) return 'Discord';
    if (isTikTokUrl) return 'TikTok';
    if (isLinkedInUrl) return 'LinkedIn';
    if (isRedditUrl) return 'Reddit';

    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return 'Unknown';
    }
  }

  // Enhanced platform icon detection
  IconData get platformIcon {
    if (isTwitchUrl) return Icons.live_tv;
    if (isYouTubeUrl) return Icons.play_circle_outline;
    if (isTwitterUrl) return Icons.alternate_email;
    if (isFacebookUrl) return Icons.facebook;
    if (isInstagramUrl) return Icons.photo_camera;
    if (isDiscordUrl) return Icons.chat;
    if (isTikTokUrl) return Icons.music_note;
    if (isLinkedInUrl) return Icons.work;
    if (isRedditUrl) return Icons.forum;
    return Icons.link;
  }

  // Enhanced platform color detection
  Color get platformColor {
    if (isTwitchUrl) return const Color(0xFF9146FF);
    if (isYouTubeUrl) return const Color(0xFFFF0000);
    if (isTwitterUrl) return const Color(0xFF1DA1F2);
    if (isFacebookUrl) return const Color(0xFF1877F2);
    if (isInstagramUrl) return const Color(0xFFE4405F);
    if (isDiscordUrl) return const Color(0xFF5865F2);
    if (isTikTokUrl) return const Color(0xFF000000);
    if (isLinkedInUrl) return const Color(0xFF0077B5);
    if (isRedditUrl) return const Color(0xFFFF4500);
    return Colors.blue;
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
    networkType,
  ];
}

