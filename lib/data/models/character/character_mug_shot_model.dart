// lib/data/models/character_mug_shot_model.dart

import '../../../domain/entities/character/character_mug_shot.dart';

class CharacterMugShotModel extends CharacterMugShot {
  const CharacterMugShotModel({
    required super.id,
    required super.checksum,
    required super.imageId,
    required super.height,
    required super.width,
    super.alphaChannel,
    super.animated,
    super.url,
  });

  factory CharacterMugShotModel.fromJson(Map<String, dynamic> json) {
    return CharacterMugShotModel(
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
      'alpha_channel': alphaChannel,
      'animated': animated,
      'height': height,
      'image_id': imageId,
      'url': url,
      'width': width,
    };
  }
}