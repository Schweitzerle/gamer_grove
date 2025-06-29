// ===== EVENT MODEL =====
// lib/data/models/event/event_model.dart
import '../../../domain/entities/event/event.dart';

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
    super.eventLogoId,
    super.liveStreamUrl,
    super.eventNetworkIds,
    super.gameIds,
    super.videoIds,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      slug: json['slug'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      startTime: _parseDateTime(json['start_time']),
      endTime: _parseDateTime(json['end_time']),
      timeZone: json['time_zone'],
      eventLogoId: json['event_logo'],
      liveStreamUrl: json['live_stream_url'],
      eventNetworkIds: _parseIdList(json['event_networks']),
      gameIds: _parseIdList(json['games']),
      videoIds: _parseIdList(json['videos']),
    );
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

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

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
      'event_logo': eventLogoId,
      'live_stream_url': liveStreamUrl,
      'event_networks': eventNetworkIds,
      'games': gameIds,
      'videos': videoIds,
    };
  }
}
