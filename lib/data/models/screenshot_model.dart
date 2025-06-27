// lib/data/models/screenshot_model.dart
import '../../domain/entities/screenshot.dart';

class ScreenshotModel extends Screenshot {
  const ScreenshotModel({
    required super.id,
    required super.checksum,
    required super.imageId,
    required super.height,
    required super.width,
    super.alphaChannel,
    super.animated,
    super.gameId,
    super.url,
  });

  factory ScreenshotModel.fromJson(Map<String, dynamic> json) {
    return ScreenshotModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      imageId: json['image_id'] ?? '',
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      alphaChannel: json['alpha_channel'] ?? false,
      animated: json['animated'] ?? false,
      gameId: json['game'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'alpha_channel': alphaChannel,
      'animated': animated,
      'game': gameId,
      'height': height,
      'image_id': imageId,
      'url': url,
      'width': width,
    };
  }
}