// ===== PLATFORM WEBSITE ENTITY =====
// File: lib/domain/entities/platform/platform_website.dart

import 'package:equatable/equatable.dart';
import '../website/website_type.dart';

class PlatformWebsite extends Equatable {
  final int id;
  final String checksum;
  final String url;
  final bool trusted;
  final int? platformId;
  final int? typeId;
  final WebsiteType? type;

  // Legacy support
  final WebsiteCategory? category;

  const PlatformWebsite({
    required this.id,
    required this.checksum,
    required this.url,
    this.trusted = false,
    this.platformId,
    this.typeId,
    this.type,
    this.category,
  });

  // Helper getters (same as Website entity)
  String get typeName => type?.type ?? category?.typeName ?? 'Unknown';
  bool get isOfficial => typeName.toLowerCase() == 'official';
  bool get isSocialMedia => type?.isSocialMedia ?? false;
  bool get isStore => type?.isStore ?? false;
  bool get isWiki => type?.isWiki ?? false;

  String get domain {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  @override
  List<Object?> get props => [
    id,
    checksum,
    url,
    trusted,
    platformId,
    typeId,
    type,
    category,
  ];
}