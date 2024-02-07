import 'package:gamer_grove/model/igdb_models/event_networkj.dart';

class NetworkType {
  int id;
  final String? checksum;
  final int? createdAt;
  final List<EventNetwork>? eventNetworks;
  final String? name;
  final int? updatedAt;

  NetworkType({
    required this.id,
    this.checksum,
    this.createdAt,
    this.eventNetworks,
    this.name,
    this.updatedAt,
  });

  factory NetworkType.fromJson(Map<String, dynamic> json) {
    return NetworkType(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      eventNetworks: json['event_networks'] != null
          ? List<EventNetwork>.from(
        json['event_networks'].map((eventNetwork) {
          if (eventNetwork is int) {
            return EventNetwork(id: eventNetwork);
          } else {
            return EventNetwork.fromJson(eventNetwork);
          }
        }),
      )
          : null,
      name: json['name'],
      updatedAt: json['updated_at'], id: json['id'],
    );
  }
}
