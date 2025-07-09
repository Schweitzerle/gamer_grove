// ==================================================
// ENHANCED EVENT NETWORK MODEL
// ==================================================

// lib/data/models/event/event_network_model.dart (ENHANCED)
import '../../../domain/entities/event/event_network.dart';
import '../../../domain/entities/event/network_type.dart';
import 'network_type_model.dart';

class EventNetworkModel extends EventNetwork {
  const EventNetworkModel({
    required super.id,
    required super.checksum,
    required super.url,
    super.eventId,
    super.networkTypeId,
    super.createdAt,
    super.updatedAt,
    super.networkType, // Enhanced field
  });

  factory EventNetworkModel.fromJson(Map<String, dynamic> json) {
    return EventNetworkModel(
      id: _parseId(json['id']) ?? 0,
      checksum: _parseString(json['checksum']) ?? '',
      url: _parseString(json['url']) ?? '',
      eventId: _parseId(json['event']),
      networkTypeId: _parseId(json['network_type']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      networkType: _extractNetworkType(json['network_type']),
    );
  }

  // Helper parsing methods
  static int? _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is Map && value['id'] is int) return value['id'];
    return null;
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

  static NetworkType? _extractNetworkType(dynamic networkType) {
    if (networkType is Map<String, dynamic>) {
      try {
        return NetworkTypeModel.fromJson(networkType);
      } catch (e) {
        print('⚠️ EventNetworkModel: Failed to parse network type: $networkType - Error: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'url': url,
      'event': eventId,
      'network_type': networkType != null ? {
        'id': networkType!.id,
        'name': networkType!.name,
        'checksum': networkType!.checksum,
      } : networkTypeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

