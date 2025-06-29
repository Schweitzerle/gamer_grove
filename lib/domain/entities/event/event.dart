// ===== EVENT ENTITY =====
// lib/domain/entities/event/event.dart
import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final String? description;
  final String? slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Event timing
  final DateTime? startTime; // UTC
  final DateTime? endTime; // UTC
  final String? timeZone;

  // Event content
  final int? eventLogoId;
  final String? liveStreamUrl;
  final List<int> eventNetworkIds;
  final List<int> gameIds; // Games featured in the event
  final List<int> videoIds; // Trailers featured in the event

  const Event({
    required this.id,
    required this.checksum,
    required this.name,
    this.description,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.startTime,
    this.endTime,
    this.timeZone,
    this.eventLogoId,
    this.liveStreamUrl,
    this.eventNetworkIds = const [],
    this.gameIds = const [],
    this.videoIds = const [],
  });

  // Helper getters
  bool get hasLogo => eventLogoId != null;
  bool get hasLiveStream => liveStreamUrl != null && liveStreamUrl!.isNotEmpty;
  bool get hasNetworks => eventNetworkIds.isNotEmpty;
  bool get hasGames => gameIds.isNotEmpty;
  bool get hasVideos => videoIds.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;

  // Event status helpers
  bool get isUpcoming {
    if (startTime == null) return false;
    return startTime!.isAfter(DateTime.now());
  }

  bool get isLive {
    final now = DateTime.now();
    if (startTime == null || endTime == null) return false;
    return now.isAfter(startTime!) && now.isBefore(endTime!);
  }

  bool get hasEnded {
    if (endTime == null) return false;
    return endTime!.isBefore(DateTime.now());
  }

  bool get hasStarted {
    if (startTime == null) return false;
    return startTime!.isBefore(DateTime.now());
  }

  // Duration helpers
  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }

  Duration? get timeUntilStart {
    if (startTime == null || hasStarted) return null;
    return startTime!.difference(DateTime.now());
  }

  Duration? get timeUntilEnd {
    if (endTime == null || hasEnded) return null;
    return endTime!.difference(DateTime.now());
  }

  // Event type helpers
  bool get isGamingEvent => gameIds.isNotEmpty;
  bool get hasTrailers => videoIds.isNotEmpty;

  // Counters
  int get networkCount => eventNetworkIds.length;
  int get gameCount => gameIds.length;
  int get videoCount => videoIds.length;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    description,
    slug,
    createdAt,
    updatedAt,
    startTime,
    endTime,
    timeZone,
    eventLogoId,
    liveStreamUrl,
    eventNetworkIds,
    gameIds,
    videoIds,
  ];
}



