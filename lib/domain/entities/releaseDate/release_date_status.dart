// ===== RELEASE DATE STATUS ENTITY =====
// lib/domain/entities/release_date/release_date_status.dart
import 'package:equatable/equatable.dart';

class ReleaseDateStatus extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReleaseDateStatus({
    required this.id,
    required this.checksum,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  bool get hasDescription => description != null && description!.isNotEmpty;

  // Status type detection
  bool get isReleased => name.toLowerCase().contains('released') ||
      name.toLowerCase().contains('available');
  bool get isCancelled => name.toLowerCase().contains('cancelled') ||
      name.toLowerCase().contains('canceled');
  bool get isDelayed => name.toLowerCase().contains('delayed') ||
      name.toLowerCase().contains('postponed');
  bool get isAnnounced => name.toLowerCase().contains('announced');
  bool get isEarlyAccess => name.toLowerCase().contains('early access') ||
      name.toLowerCase().contains('beta');
  bool get isTbd => name.toLowerCase().contains('tbd') ||
      name.toLowerCase().contains('to be determined');

  String get displayName => name;
  String get displayDescription => description ?? '';

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    description,
    createdAt,
    updatedAt,
  ];
}