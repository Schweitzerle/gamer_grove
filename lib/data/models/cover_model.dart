// lib/data/models/cover_model.dart
import '../../domain/entities/cover.dart';

class CoverModel extends Cover {
  const CoverModel({
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

  factory CoverModel.fromJson(Map<String, dynamic> json) {
    return CoverModel(
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