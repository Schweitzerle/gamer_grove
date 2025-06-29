// ===== EVENT LOGO MODEL =====
// lib/data/models/event/event_logo_model.dart
import '../../../domain/entities/event/event_logo.dart';

class EventLogoModel extends EventLogo {
  const EventLogoModel({
    required super.id,
    required super.checksum,
    required super.imageId,
    required super.height,
    required super.width,
    super.alphaChannel = false,
    super.animated = false,
    super.eventId,
    super.url,
    super.createdAt,
    super.updatedAt,
  });

  factory EventLogoModel.fromJson(Map<String, dynamic> json) {
    return EventLogoModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      imageId: json['image_id'] ?? '',
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      alphaChannel: json['alpha_channel'] ?? false,
      animated: json['animated'] ?? false,
      eventId: json['event'],
      url: json['url'],
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
      'image_id': imageId,
      'height': height,
      'width': width,
      'alpha_channel': alphaChannel,
      'animated': animated,
      'event': eventId,
      'url': url,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Factory method for easy creation with IGDB image URL
  factory EventLogoModel.withImageUrl({
    required int id,
    required String checksum,
    required String imageId,
    required int height,
    required int width,
    bool alphaChannel = false,
    bool animated = false,
    int? eventId,
    String? customUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventLogoModel(
      id: id,
      checksum: checksum,
      imageId: imageId,
      height: height,
      width: width,
      alphaChannel: alphaChannel,
      animated: animated,
      eventId: eventId,
      url: customUrl ?? 'https://images.igdb.com/igdb/image/upload/t_logo_med/$imageId.jpg',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

