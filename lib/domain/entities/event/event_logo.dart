// ==================================================
// EVENT LOGO ENTITY (ENHANCED)
// ==================================================

// lib/domain/entities/event/event_logo.dart (ENHANCED)
import 'dart:ui';

import 'package:equatable/equatable.dart';

class EventLogo extends Equatable {
  final int id;
  final String checksum;
  final String imageId;
  final int height;
  final int width;
  final bool alphaChannel;
  final bool animated;
  final int? eventId;
  final String? url;
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

  // ==========================================
  // ENHANCED HELPER GETTERS
  // ==========================================

  bool get isAnimated => animated;
  bool get hasAlphaChannel => alphaChannel;
  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get isSquare => width == height;
  bool get isLandscape => width > height;
  bool get isPortrait => height > width;

  double get aspectRatio => width / height;
  Size get size => Size(width.toDouble(), height.toDouble());

  /// Get IGDB image URL from imageId
  String get igdbImageUrl {
    return 'https://images.igdb.com/igdb/image/upload/t_logo_med/$imageId.jpg';
  }

  /// Get IGDB image URL with custom size
  String getIgdbImageUrl({String size = 'logo_med'}) {
    return 'https://images.igdb.com/igdb/image/upload/t_$size/$imageId.jpg';
  }

  /// Get best available URL
  String get bestUrl => url ?? igdbImageUrl;

  /// Get thumbnail URL
  String get thumbnailUrl => getIgdbImageUrl(size: 'logo_med');

  /// Get HD URL
  String get hdUrl => getIgdbImageUrl(size: 'logo_med'); // IGDB only has one logo size

  @override
  List<Object?> get props => [
    id,
    checksum,
    imageId,
    height,
    width,
    alphaChannel,
    animated,
    eventId,
    url,
    createdAt,
    updatedAt,
  ];
}

