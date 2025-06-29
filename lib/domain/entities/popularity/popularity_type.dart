// ===== POPULARITY TYPE ENTITY =====
// lib/domain/entities/popularity/popularity_type.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/popularity/popularity_primitive.dart';

class PopularityType extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // External source references
  final int? externalPopularitySourceId;

  // DEPRECATED but still useful
  final PopularitySourceEnum? popularitySourceEnum;

  const PopularityType({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.externalPopularitySourceId,
    this.popularitySourceEnum,
  });

  // Helper getters
  bool get hasExternalSource => externalPopularitySourceId != null;
  bool get isFromSteam => popularitySourceEnum == PopularitySourceEnum.steam;
  bool get isFromIgdb => popularitySourceEnum == PopularitySourceEnum.igdb;

  String get displayName => name;

  String get sourceDisplayName {
    if (popularitySourceEnum != null) {
      return popularitySourceEnum!.displayName;
    }
    return 'Unknown Source';
  }

  // Common popularity type detection
  bool get isUserRating => name.toLowerCase().contains('rating') ||
      name.toLowerCase().contains('user');
  bool get isWishlist => name.toLowerCase().contains('wishlist') ||
      name.toLowerCase().contains('want');
  bool get isFollowing => name.toLowerCase().contains('follow') ||
      name.toLowerCase().contains('track');
  bool get isViews => name.toLowerCase().contains('view') ||
      name.toLowerCase().contains('visit');
  bool get isDownloads => name.toLowerCase().contains('download') ||
      name.toLowerCase().contains('install');
  bool get isPurchases => name.toLowerCase().contains('purchase') ||
      name.toLowerCase().contains('sale') ||
      name.toLowerCase().contains('buy');

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    createdAt,
    updatedAt,
    externalPopularitySourceId,
    popularitySourceEnum,
  ];
}