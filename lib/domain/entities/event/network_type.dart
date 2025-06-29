// ===== NETWORK TYPE ENTITY =====
// lib/domain/entities/event/network_type.dart
import 'package:equatable/equatable.dart';

class NetworkType extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final List<int> eventNetworkIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NetworkType({
    required this.id,
    required this.checksum,
    required this.name,
    this.eventNetworkIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  bool get hasEventNetworks => eventNetworkIds.isNotEmpty;
  int get eventNetworkCount => eventNetworkIds.length;

  // Common network type checks
  bool get isStreamingPlatform => name.toLowerCase().contains('stream') ||
      name.toLowerCase().contains('twitch') ||
      name.toLowerCase().contains('youtube');

  bool get isSocialMedia => name.toLowerCase().contains('twitter') ||
      name.toLowerCase().contains('facebook') ||
      name.toLowerCase().contains('instagram') ||
      name.toLowerCase().contains('discord');

  bool get isOfficialWebsite => name.toLowerCase().contains('official') ||
      name.toLowerCase().contains('website');

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    eventNetworkIds,
    createdAt,
    updatedAt,
  ];
}
