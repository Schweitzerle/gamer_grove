// ===== EVENT LOGO ENTITY =====
// lib/domain/entities/event/event_logo.dart
import 'package:equatable/equatable.dart';

class EventLogo extends Equatable {
  final int id;
  final String checksum;
  final bool alphaChannel;
  final bool animated;
  final int? eventId;
  final int height;
  final String imageId;
  final String? url;
  final int width;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventLogo({
    required this.id,
    required this.checksum,
    required this.imageId,
    required this.height,
    required this.width,
    this.alphaChannel = false,
    this.animated = false,
    this.eventId,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters for different logo sizes (IGDB image API)
  String get thumbUrl => 'https://images.igdb.com/igdb/image/upload/t_thumb/$imageId.jpg';
  String get logoMedUrl => 'https://images.igdb.com/igdb/image/upload/t_logo_med/$imageId.jpg';
  String get logoMed2xUrl => 'https://images.igdb.com/igdb/image/upload/t_logo_med_2x/$imageId.jpg';
  String get microUrl => 'https://images.igdb.com/igdb/image/upload/t_micro/$imageId.jpg';
  String get hdUrl => 'https://images.igdb.com/igdb/image/upload/t_720p/$imageId.jpg';

  // Helper getters
  bool get isAssociatedWithEvent => eventId != null;
  bool get hasCustomUrl => url != null && url!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    checksum,
    alphaChannel,
    animated,
    eventId,
    height,
    imageId,
    url,
    width,
    createdAt,
    updatedAt,
  ];
}
