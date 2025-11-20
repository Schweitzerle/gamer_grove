// lib/domain/entities/screenshot.dart
import 'package:equatable/equatable.dart';

class Screenshot extends Equatable {

  const Screenshot({
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
  final int id;
  final String checksum;
  final bool alphaChannel;
  final bool animated;
  final int? gameId;
  final int height;
  final String imageId;
  final String? url;
  final int width;

  // Helper getters for different screenshot sizes (IGDB image API)
  String get thumbUrl => 'https://images.igdb.com/igdb/image/upload/t_thumb/$imageId.jpg';
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