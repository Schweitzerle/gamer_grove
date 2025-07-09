// ==================================================
// ENHANCED EVENT MODEL WITH FULL OBJECT PARSING
// ==================================================

// lib/data/models/event/event_model.dart (ENHANCED)
import '../../../domain/entities/event/event.dart';
import '../../../domain/entities/event/event_logo.dart';
import '../../../domain/entities/event/event_network.dart';
import '../../../domain/entities/event/network_type.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/game/game_video.dart';
import 'event_logo_model.dart';
import 'event_network_model.dart';
import 'network_type_model.dart';
import '../game/game_model.dart';
import '../game/game_video_model.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.description,
    super.slug,
    super.createdAt,
    super.updatedAt,
    super.startTime,
    super.endTime,
    super.timeZone,
    // Enhanced fields
    super.eventLogo,
    super.liveStreamUrl,
    super.eventNetworks,
    super.games,
    super.videos,
    // Legacy fields
    super.eventLogoId,
    super.eventNetworkIds,
    super.gameIds,
    super.videoIds,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: _parseId(json['id']),
      checksum: _parseString(json['checksum']) ?? '',
      name: _parseString(json['name']) ?? 'Unknown Event',
      description: _parseString(json['description']),
      slug: _parseString(json['slug']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      startTime: _parseDateTime(json['start_time']),
      endTime: _parseDateTime(json['end_time']),
      timeZone: _parseString(json['time_zone']),

      // Enhanced object parsing
      eventLogo: _extractEventLogo(json['event_logo']),
      liveStreamUrl: _parseString(json['live_stream_url']),
      eventNetworks: _extractEventNetworks(json['event_networks']),
      games: _extractGames(json['games']),
      videos: _extractVideos(json['videos']),

      // Legacy ID parsing for backward compatibility
      eventLogoId: _parseId(json['event_logo']),
      eventNetworkIds: _parseIdList(json['event_networks']),
      gameIds: _parseIdList(json['games']),
      videoIds: _parseIdList(json['videos']),
    );
  }

  // ==========================================
  // PARSING HELPER METHODS
  // ==========================================

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is Map && value['id'] is int) return value['id'];
    return 0;
  }

  static String? _parseString(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  static List<int> _parseIdList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is int || (item is Map && item['id'] is int))
          .map((item) => item is int ? item : item['id'] as int)
          .toList();
    }
    return [];
  }

  // ==========================================
  // ENHANCED OBJECT EXTRACTION METHODS
  // ==========================================

  /// Extract EventLogo object from JSON
  static EventLogo? _extractEventLogo(dynamic eventLogo) {
    if (eventLogo is Map<String, dynamic>) {
      try {
        return EventLogoModel.fromJson(eventLogo);
      } catch (e) {
        print('⚠️ EventModel: Failed to parse event logo: $eventLogo - Error: $e');
        return null;
      }
    }
    return null;
  }

  /// Extract EventNetwork objects from JSON
  static List<EventNetwork> _extractEventNetworks(dynamic eventNetworks) {
    if (eventNetworks is List) {
      return eventNetworks
          .where((item) => item is Map)
          .map((item) {
        try {
          return EventNetworkModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ EventModel: Failed to parse event network: $item - Error: $e');
          return null;
        }
      })
          .where((network) => network != null)
          .cast<EventNetwork>()
          .toList();
    }
    return [];
  }

  /// Extract Game objects from JSON
  static List<Game> _extractGames(dynamic games) {
    if (games is List) {
      return games
          .where((item) => item is Map)
          .map((item) {
        try {
          return GameModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ EventModel: Failed to parse game: $item - Error: $e');
          return null;
        }
      })
          .where((game) => game != null)
          .cast<Game>()
          .toList();
    }
    return [];
  }

  /// Extract GameVideo objects from JSON
  static List<GameVideo> _extractVideos(dynamic videos) {
    if (videos is List) {
      return videos
          .where((item) => item is Map)
          .map((item) {
        try {
          return GameVideoModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ EventModel: Failed to parse video: $item - Error: $e');
          return null;
        }
      })
          .where((video) => video != null)
          .cast<GameVideo>()
          .toList();
    }
    return [];
  }

  // ==========================================
  // ENHANCED SERIALIZATION
  // ==========================================

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'name': name,
      'description': description,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'time_zone': timeZone,
      'live_stream_url': liveStreamUrl,

      // Enhanced object serialization
      'event_logo': eventLogo != null ? {
        'id': eventLogo!.id,
        'image_id': eventLogo!.imageId,
        'url': eventLogo!.url,
        'width': eventLogo!.width,
        'height': eventLogo!.height,
      } : null,

      'event_networks': eventNetworks.map((network) => {
        'id': network.id,
        'url': network.url,
        'network_type': network.networkType != null ? {
          'id': network.networkType!.id,
          'name': network.networkType!.name,
        } : null,
      }).toList(),

      'games': games.map((game) => {
        'id': game.id,
        'name': game.name,
        'slug': game.slug,
        'cover': game.coverUrl != null ? {'url': game.coverUrl} : null,
      }).toList(),

      'videos': videos.map((video) => {
        'id': video.id,
        'name': video.title,
        'video_id': video.videoId,
      }).toList(),

      // Legacy ID fields for backward compatibility
      'event_logo_id': eventLogoId,
      'event_network_ids': eventNetworkIds,
      'game_ids': gameIds,
      'video_ids': videoIds,
    };
  }

  // ==========================================
  // FACTORY METHODS FOR TESTING
  // ==========================================

  /// Factory method for creating test events
  factory EventModel.test({
    int id = 1,
    String name = 'Test Event',
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventLogo? eventLogo,
    List<EventNetwork> eventNetworks = const [],
    List<Game> games = const [],
    List<GameVideo> videos = const [],
    String? liveStreamUrl,
  }) {
    return EventModel(
      id: id,
      checksum: 'test-checksum',
      name: name,
      description: description,
      slug: name.toLowerCase().replaceAll(' ', '-'),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      startTime: startTime,
      endTime: endTime,
      timeZone: 'UTC',
      eventLogo: eventLogo,
      liveStreamUrl: liveStreamUrl,
      eventNetworks: eventNetworks,
      games: games,
      videos: videos,
      eventLogoId: eventLogo?.id,
      eventNetworkIds: eventNetworks.map((n) => n.id).toList(),
      gameIds: games.map((g) => g.id).toList(),
      videoIds: videos.map((v) => v.id).toList(),
    );
  }

  /// Factory method for creating live events
  factory EventModel.live({
    required int id,
    required String name,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required String liveStreamUrl,
    EventLogo? eventLogo,
    List<Game> games = const [],
  }) {
    return EventModel.test(
      id: id,
      name: name,
      description: description,
      startTime: startTime,
      endTime: endTime,
      eventLogo: eventLogo,
      games: games,
      liveStreamUrl: liveStreamUrl,
    );
  }

  /// Factory method for creating upcoming events
  factory EventModel.upcoming({
    required int id,
    required String name,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    EventLogo? eventLogo,
    List<Game> games = const [],
  }) {
    return EventModel.test(
      id: id,
      name: name,
      description: description,
      startTime: startTime,
      endTime: endTime,
      eventLogo: eventLogo,
      games: games,
    );
  }
}

