
// ===== EVENT NETWORK MODEL =====
// lib/data/models/event/event_network_model.dart
import '../../../domain/entities/event/event_network.dart';

class EventNetworkModel extends EventNetwork {
  const EventNetworkModel({
    required super.id,
    required super.checksum,
    required super.url,
    super.eventId,
    super.networkTypeId,
    super.createdAt,
    super.updatedAt,
  });

  factory EventNetworkModel.fromJson(Map<String, dynamic> json) {
    return EventNetworkModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      url: json['url'] ?? '',
      eventId: json['event'],
      networkTypeId: json['network_type'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
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
      'url': url,
      'event': eventId,
      'network_type': networkTypeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}