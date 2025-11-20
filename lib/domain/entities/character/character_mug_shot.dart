// lib/domain/entities/character_mug_shot.dart
import 'package:equatable/equatable.dart';

class CharacterMugShot extends Equatable {

  const CharacterMugShot({
    required this.id,
    required this.checksum,
    required this.imageId,
    required this.height,
    required this.width,
    this.alphaChannel = false,
    this.animated = false,
    this.url,
  });
  final int id;
  final String checksum;
  final bool alphaChannel;
  final bool animated;
  final int height;
  final String imageId;
  final String? url;
  final int width;

  // Helper getters for different mug shot sizes (IGDB image API)
  String get thumbUrl => 'https://images.igdb.com/igdb/image/upload/t_thumb/$imageId.jpg';
  String get microUrl => 'https://images.igdb.com/igdb/image/upload/t_micro/$imageId.jpg';
  String get mediumUrl => 'https://images.igdb.com/igdb/image/upload/t_logo_med/$imageId.jpg';
  String get largeUrl => 'https://images.igdb.com/igdb/image/upload/t_720p/$imageId.jpg';

  @override
  List<Object?> get props => [
    id,
    checksum,
    alphaChannel,
    animated,
    height,
    imageId,
    url,
    width,
  ];
}