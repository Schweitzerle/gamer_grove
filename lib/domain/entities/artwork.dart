// lib/domain/entities/artwork.dart
import 'package:equatable/equatable.dart';

class Artwork extends Equatable {
  final int id;
  final String checksum;
  final bool alphaChannel;
  final bool animated;
  final int? gameId;
  final int height;
  final String imageId;
  final String? url;
  final int width;

  const Artwork({
    required this.id,
    required this.checksum,
    required this.imageId,
    required this.height,
    required this.width,
    this.alphaChannel = false,
    this.animated = false,
    this.gameId,
    this.url,
  });

  // Helper getters for different image sizes (IGDB image API)
  String get thumbUrl => 'https://images.igdb.com/igdb/image/upload/t_thumb/$imageId.jpg';
  String get coverSmallUrl => 'https://images.igdb.com/igdb/image/upload/t_cover_small/$imageId.jpg';
  String get coverBigUrl => 'https://images.igdb.com/igdb/image/upload/t_cover_big/$imageId.jpg';
  String get logoMedUrl => 'https://images.igdb.com/igdb/image/upload/t_logo_med/$imageId.jpg';
  String get screenshotMedUrl => 'https://images.igdb.com/igdb/image/upload/t_screenshot_med/$imageId.jpg';
  String get screenshotBigUrl => 'https://images.igdb.com/igdb/image/upload/t_screenshot_big/$imageId.jpg';
  String get screenshotHugeUrl => 'https://images.igdb.com/igdb/image/upload/t_screenshot_huge/$imageId.jpg';
  String get hdUrl => 'https://images.igdb.com/igdb/image/upload/t_720p/$imageId.jpg';
  String get fullHdUrl => 'https://images.igdb.com/igdb/image/upload/t_1080p/$imageId.jpg';

  @override
  List<Object?> get props => [
    id,
    checksum,
    alphaChannel,
    animated,
    gameId,
    height,
    imageId,
    url,
    width,
  ];
}