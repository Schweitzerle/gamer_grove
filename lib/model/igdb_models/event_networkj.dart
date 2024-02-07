import 'package:gamer_grove/model/igdb_models/network_type.dart';

class EventNetwork {
  int id;
  final String? checksum;
  final int? createdAt;
  final int? event;
  final NetworkType? networkType;
  final int? updatedAt;
  final String? url;

  EventNetwork({
    required this.id,
    this.checksum,
    this.createdAt,
    this.event,
    this.networkType,
    this.updatedAt,
    this.url,
  });

  factory EventNetwork.fromJson(Map<String, dynamic> json) {
    return EventNetwork(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      event: json['event'],
      networkType: json['network_type'] != null
          ? (json['network_type'] is int
          ? NetworkType(id: json['event_logo'])
          : NetworkType.fromJson(json['event_logo']))
          : null,

      updatedAt: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }
}
