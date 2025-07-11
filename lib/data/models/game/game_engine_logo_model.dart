// lib/data/models/game/game_engine_logo_model.dart
import '../../../domain/entities/game/game_engine_logo.dart';

class GameEngineLogoModel extends GameEngineLogo {
  const GameEngineLogoModel({
    required super.id,
    required super.checksum,
    required super.imageId,
    required super.height,
    required super.width,
    super.alphaChannel = false,
    super.animated = false,
    super.url,
  });

  factory GameEngineLogoModel.fromJson(Map<String, dynamic> json) {
    return GameEngineLogoModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      imageId: json['image_id'] ?? '',
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      alphaChannel: json['alpha_channel'] ?? false,
      animated: json['animated'] ?? false,
      url: json['url'],
    );
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
      'url': url,
    };
  }

  // Factory method for easy creation with IGDB image URL
  factory GameEngineLogoModel.withImageUrl({
    required int id,
    required String checksum,
    required String imageId,
    required int height,
    required int width,
    bool alphaChannel = false,
    bool animated = false,
    String? customUrl,
  }) {
    return GameEngineLogoModel(
      id: id,
      checksum: checksum,
      imageId: imageId,
      height: height,
      width: width,
      alphaChannel: alphaChannel,
      animated: animated,
      url: customUrl ?? 'https://images.igdb.com/igdb/image/upload/t_logo_med/$imageId.jpg',
    );
  }
}