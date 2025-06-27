// lib/domain/entities/cover.dart
import 'package:equatable/equatable.dart';

class Cover extends Equatable {
  final int id;
  final String checksum;
  final bool alphaChannel;
  final bool animated;
  final int? gameId;
  final int height;
  final String imageId;
  final String? url;
  final int width;

  const Cover({
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

  // Helper getters for different cover sizes (IGDB image API)
  String get thumbUrl => 'https://images.igdb.com/igdb/image/upload/t_thumb/$imageId.jpg';
  String get coverSmallUrl => 'https://images.igdb.com/igdb/image/upload/t_cover_small/$imageId.jpg';
  String get coverSmall2xUrl => 'https://images.igdb.com/igdb/image/upload/t_cover_small_2x/$imageId.jpg';
  String get coverBigUrl => 'https://images.igdb.com/igdb/image/upload/t_cover_big/$imageId.jpg';
  String get coverBig2xUrl => 'https://images.igdb.com/igdb/image/upload/t_cover_big_2x/$imageId.jpg';
  String get microUrl => 'https://images.igdb.com/igdb/image/upload/t_micro/$imageId.jpg';

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