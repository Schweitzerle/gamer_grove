// ==================================================
// ENHANCED EVENT ENTITY WITH FULL OBJECTS
// ==================================================

// lib/domain/entities/event/event.dart (ENHANCED)
import 'package:equatable/equatable.dart';
import '../game/game.dart';
import '../game/game_video.dart';
import 'event_logo.dart';
import 'event_network.dart';

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

  // Event content - ENHANCED with actual objects
  final EventLogo? eventLogo; // 🆕 Full EventLogo object instead of ID
  final String? liveStreamUrl;
  final List<EventNetwork> eventNetworks; // 🆕 Full EventNetwork objects instead of IDs
  final List<Game> games; // 🆕 Full Game objects instead of IDs
  final List<GameVideo> videos; // 🆕 Full GameVideo objects instead of IDs

  // Legacy ID fields for backward compatibility
  final int? eventLogoId;
  final List<int> eventNetworkIds;
  final List<int> gameIds;
  final List<int> videoIds;

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
    // Enhanced fields
    this.eventLogo,
    this.liveStreamUrl,
    this.eventNetworks = const [],
    this.games = const [],
    this.videos = const [],
    // Legacy fields
    this.eventLogoId,
    this.eventNetworkIds = const [],
    this.gameIds = const [],
    this.videoIds = const [],
  });

  // ==========================================
  // ENHANCED HELPER GETTERS
  // ==========================================

  bool get hasLogo => eventLogo != null && eventLogo!.bestUrl.isNotEmpty;
  bool get hasLogoObject => eventLogo != null;
  bool get hasLiveStream => liveStreamUrl != null && liveStreamUrl!.isNotEmpty;
  bool get hasNetworks => eventNetworks.isNotEmpty || eventNetworkIds.isNotEmpty;
  bool get hasNetworkObjects => eventNetworks.isNotEmpty;
  bool get hasGames => games.isNotEmpty || gameIds.isNotEmpty;
  bool get hasGameObjects => games.isNotEmpty;
  bool get hasVideos => videos.isNotEmpty || videoIds.isNotEmpty;
  bool get hasVideoObjects => videos.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;

  // Event status helpers
  bool get isUpcoming {
    if (startTime == null) return false;
    return startTime!.isAfter(DateTime.now());
  }

  bool get isLive {
    final now = DateTime.now();
    if (startTime == null) return false;
    if (endTime == null) return startTime!.isBefore(now);
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
  bool get isGamingEvent => games.isNotEmpty || gameIds.isNotEmpty;
  bool get hasTrailers => videos.isNotEmpty || videoIds.isNotEmpty;

  // Enhanced counters
  int get networkCount => eventNetworks.isNotEmpty ? eventNetworks.length : eventNetworkIds.length;
  int get gameCount => games.isNotEmpty ? games.length : gameIds.length;
  int get videoCount => videos.isNotEmpty ? videos.length : videoIds.length;

  // ==========================================
  // ENHANCED OBJECT ACCESS
  // ==========================================

  /// Get event logo URL (enhanced)
  String? get eventLogoUrl {
    if (eventLogo != null) {
      return eventLogo!.url ?? eventLogo!.igdbImageUrl;
    }
    return null;
  }

  /// Get event logo image ID (enhanced)
  String? get eventLogoImageId {
    if (eventLogo != null) {
      return eventLogo!.imageId;
    }
    return null;
  }

  /// Get all social media networks
  List<EventNetwork> get socialMediaNetworks {
    return eventNetworks.where((network) => network.isSocialMediaUrl).toList();
  }

  /// Get all streaming networks
  List<EventNetwork> get streamingNetworks {
    return eventNetworks.where((network) => network.isStreamingUrl).toList();
  }

  /// Get featured games (alias for games)
  List<Game> get featuredGames => games;

  /// Get event trailers (alias for videos)
  List<GameVideo> get eventTrailers => videos;

  /// Get main franchise games from featured games
  List<Game> get mainFranchiseGames {
    return games.where((game) => game.mainFranchise != null).toList();
  }

  /// Get upcoming games from featured games
  List<Game> get upcomingGames {
    return games.where((game) => game.firstReleaseDate != null &&
        game.firstReleaseDate!.isAfter(DateTime.now())).toList();
  }

  /// Get released games from featured games
  List<Game> get releasedGames {
    return games.where((game) => game.firstReleaseDate != null &&
        game.firstReleaseDate!.isBefore(DateTime.now())).toList();
  }

  // ==========================================
  // COPYWITH METHOD
  // ==========================================

  Event copyWith({
    int? id,
    String? checksum,
    String? name,
    String? description,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startTime,
    DateTime? endTime,
    String? timeZone,
    EventLogo? eventLogo,
    String? liveStreamUrl,
    List<EventNetwork>? eventNetworks,
    List<Game>? games,
    List<GameVideo>? videos,
    int? eventLogoId,
    List<int>? eventNetworkIds,
    List<int>? gameIds,
    List<int>? videoIds,
  }) {
    return Event(
      id: id ?? this.id,
      checksum: checksum ?? this.checksum,
      name: name ?? this.name,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeZone: timeZone ?? this.timeZone,
      eventLogo: eventLogo ?? this.eventLogo,
      liveStreamUrl: liveStreamUrl ?? this.liveStreamUrl,
      eventNetworks: eventNetworks ?? this.eventNetworks,
      games: games ?? this.games,
      videos: videos ?? this.videos,
      eventLogoId: eventLogoId ?? this.eventLogoId,
      eventNetworkIds: eventNetworkIds ?? this.eventNetworkIds,
      gameIds: gameIds ?? this.gameIds,
      videoIds: videoIds ?? this.videoIds,
    );
  }

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
    eventLogo,
    liveStreamUrl,
    eventNetworks,
    games,
    videos,
    eventLogoId,
    eventNetworkIds,
    gameIds,
    videoIds,
  ];
}

