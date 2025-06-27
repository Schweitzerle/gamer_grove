// ===== RELEASE DATE MODEL =====
// lib/data/models/release_date_model.dart
import '../../domain/entities/release_date.dart';
import '../../domain/entities/platform/platform.dart';
import 'platform/platform_model.dart';

class ReleaseDateModel extends ReleaseDate {
  const ReleaseDateModel({
    required super.id,
    super.date,
    super.platform,
    super.region,
    super.human,
  });

  factory ReleaseDateModel.fromJson(Map<String, dynamic> json) {
    return ReleaseDateModel(
      id: json['id'] ?? 0,
      date: _parseUnixTimestamp(json['date']),
      platform: _parsePlatform(json['platform']),
      region: _parseRegion(json['region']),
      human: json['human'],
    );
  }

  static DateTime? _parseUnixTimestamp(dynamic timestamp) {
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }
    return null;
  }

  static Platform? _parsePlatform(dynamic platform) {
    if (platform is Map<String, dynamic>) {
      return PlatformModel.fromJson(platform);
    }
    return null;
  }

  static ReleaseRegion _parseRegion(dynamic region) {
    if (region is int) {
      switch (region) {
        case 1: return ReleaseRegion.europe;
        case 2: return ReleaseRegion.northAmerica;
        case 3: return ReleaseRegion.australia;
        case 4: return ReleaseRegion.newZealand;
        case 5: return ReleaseRegion.japan;
        case 6: return ReleaseRegion.china;
        case 7: return ReleaseRegion.asia;
        case 8: return ReleaseRegion.worldwide;
        case 9: return ReleaseRegion.korea;
        case 10: return ReleaseRegion.brazil;
        default: return ReleaseRegion.unknown;
      }
    }
    return ReleaseRegion.unknown;
  }
}