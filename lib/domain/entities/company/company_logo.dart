// ===== COMPANY LOGO ENTITY =====
// lib/domain/entities/company/company_logo.dart
import 'package:equatable/equatable.dart';

class CompanyLogo extends Equatable {
  final int id;
  final String checksum;
  final bool alphaChannel;
  final bool animated;
  final int height;
  final String imageId;
  final String? url;
  final int width;

  const CompanyLogo({
    required this.id,
    required this.checksum,
    required this.imageId,
    required this.height,
    required this.width,
    this.alphaChannel = false,
    this.animated = false,
    this.url,
  });

  // Helper getters for different logo sizes (IGDB image API)
  String get thumbUrl => 'https://images.igdb.com/igdb/image/upload/t_thumb/$imageId.jpg';
  String get logoMedUrl => 'https://images.igdb.com/igdb/image/upload/t_logo_med/$imageId.jpg';
  String get logoMed2xUrl => 'https://images.igdb.com/igdb/image/upload/t_logo_med_2x/$imageId.jpg';
  String get microUrl => 'https://images.igdb.com/igdb/image/upload/t_micro/$imageId.jpg';

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


