// ===== NETWORK TYPE MODEL =====
// lib/data/models/event/network_type_model.dart
import '../../../domain/entities/event/network_type.dart';

class NetworkTypeModel extends NetworkType {
  const NetworkTypeModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.eventNetworkIds,
    super.createdAt,
    super.updatedAt,
  });

  factory NetworkTypeModel.fromJson(Map<String, dynamic> json) {
    return NetworkTypeModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      eventNetworkIds: _parseIdList(json['event_networks']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
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
      'event_networks': eventNetworkIds,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
