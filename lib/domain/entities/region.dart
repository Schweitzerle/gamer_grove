// ===== REGION ENTITY =====
// File: lib/domain/entities/region.dart

import 'package:equatable/equatable.dart';

class Region extends Equatable {
  final int id;
  final String checksum;
  final String category; // 'locale' or 'continent'
  final String identifier;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Region({
    required this.id,
    required this.checksum,
    required this.category,
    required this.identifier,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  bool get isLocale => category == 'locale';
  bool get isContinent => category == 'continent';

  // Get flag emoji for countries
  String? get flagEmoji {
    if (!isLocale) return null;

    switch (identifier.toUpperCase()) {
      case 'US': return '🇺🇸';
      case 'GB': return '🇬🇧';
      case 'DE': return '🇩🇪';
      case 'FR': return '🇫🇷';
      case 'ES': return '🇪🇸';
      case 'IT': return '🇮🇹';
      case 'JP': return '🇯🇵';
      case 'CN': return '🇨🇳';
      case 'KR': return '🇰🇷';
      case 'BR': return '🇧🇷';
      case 'AU': return '🇦🇺';
      case 'NZ': return '🇳🇿';
      default: return null;
    }
  }

  @override
  List<Object?> get props => [
    id,
    checksum,
    category,
    identifier,
    name,
    createdAt,
    updatedAt,
  ];
}

// Legacy Region Enum for backward compatibility
enum RegionEnum {
  europe(1),
  northAmerica(2),
  australia(3),
  newZealand(4),
  japan(5),
  china(6),
  asia(7),
  worldwide(8),
  korea(9),
  brazil(10);

  const RegionEnum(this.value);
  final int value;

  static RegionEnum fromValue(int value) {
    return values.firstWhere(
          (region) => region.value == value,
      orElse: () => worldwide,
    );
  }

  String get displayName {
    switch (this) {
      case europe: return 'Europe';
      case northAmerica: return 'North America';
      case australia: return 'Australia';
      case newZealand: return 'New Zealand';
      case japan: return 'Japan';
      case china: return 'China';
      case asia: return 'Asia';
      case worldwide: return 'Worldwide';
      case korea: return 'Korea';
      case brazil: return 'Brazil';
    }
  }
}

