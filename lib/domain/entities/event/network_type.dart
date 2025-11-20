// ==================================================
// NETWORK TYPE ENTITY (ENHANCED)
// ==================================================

// lib/domain/entities/event/network_type.dart (ENHANCED)
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class NetworkType extends Equatable {

  const NetworkType({
    required this.id,
    required this.checksum,
    required this.name,
    this.eventNetworkIds = const [],
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String name;
  final List<int> eventNetworkIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ==========================================
  // ENHANCED HELPER GETTERS
  // ==========================================

  bool get hasEventNetworks => eventNetworkIds.isNotEmpty;
  int get eventNetworkCount => eventNetworkIds.length;

  // Enhanced network type detection
  bool get isSocialMedia => name.toLowerCase().contains('social') ||
      name.toLowerCase().contains('twitter') ||
      name.toLowerCase().contains('facebook') ||
      name.toLowerCase().contains('instagram');

  bool get isStreaming => name.toLowerCase().contains('stream') ||
      name.toLowerCase().contains('twitch') ||
      name.toLowerCase().contains('youtube');

  bool get isOfficial => name.toLowerCase().contains('official') ||
      name.toLowerCase().contains('website');

  // Enhanced icon detection
  IconData get icon {
    if (isStreaming) return Icons.live_tv;
    if (isSocialMedia) return Icons.share;
    if (isOfficial) return Icons.web;
    return Icons.link;
  }

  // Enhanced color detection
  Color get color {
    if (isStreaming) return Colors.red;
    if (isSocialMedia) return Colors.blue;
    if (isOfficial) return Colors.green;
    return Colors.grey;
  }

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