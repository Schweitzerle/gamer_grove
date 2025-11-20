// ===== RELEASE DATE ENTITY (UPDATED TO IGDB API SPEC) =====
// lib/domain/entities/release_date/release_date.dart
import 'package:equatable/equatable.dart';

enum ReleaseDateCategory {
  yyyymmdd(0),
  yyyymm(1),
  yyyy(2),
  yyyyq1(3),
  yyyyq2(4),
  yyyyq3(5),
  yyyyq4(6),
  tbd(7),
  unknown(-1);

  const ReleaseDateCategory(this.value);
  final int value;

  static ReleaseDateCategory fromValue(int value) {
    return values.firstWhere(
          (category) => category.value == value,
      orElse: () => unknown,
    );
  }

  String get displayName {
    switch (this) {
      case yyyymmdd: return 'YYYY-MM-DD';
      case yyyymm: return 'YYYY-MM';
      case yyyy: return 'YYYY';
      case yyyyq1: return 'YYYY Q1';
      case yyyyq2: return 'YYYY Q2';
      case yyyyq3: return 'YYYY Q3';
      case yyyyq4: return 'YYYY Q4';
      case tbd: return 'TBD';
      default: return 'Unknown';
    }
  }
}

enum ReleaseDateRegionEnum {
  europe(1),
  northAmerica(2),
  australia(3),
  newZealand(4),
  japan(5),
  china(6),
  asia(7),
  worldwide(8),
  korea(9),
  brazil(10),
  unknown(0);

  const ReleaseDateRegionEnum(this.value);
  final int value;

  static ReleaseDateRegionEnum fromValue(int value) {
    return values.firstWhere(
          (region) => region.value == value,
      orElse: () => unknown,
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
      default: return 'Unknown';
    }
  }
}

class ReleaseDate extends Equatable { // DEPRECATED: Use releaseRegionId instead

  const ReleaseDate({
    required this.id,
    required this.checksum,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.human,
    this.month,
    this.year,
    this.gameId,
    this.platformId,
    this.dateFormatId,
    this.releaseRegionId,
    this.statusId,
    this.categoryEnum,
    this.regionEnum,
  });
  final int id;
  final String checksum;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Release date information
  final DateTime? date; // The actual release date
  final String? human; // Human readable representation
  final int? month; // Month as integer (1-12)
  final int? year; // Year in full (e.g., 2024)

  // References to other entities
  final int? gameId;
  final int? platformId;
  final int? dateFormatId;
  final int? releaseRegionId;
  final int? statusId;

  // DEPRECATED fields but still useful for backwards compatibility
  final ReleaseDateCategory? categoryEnum; // DEPRECATED: Use dateFormatId instead
  final ReleaseDateRegionEnum? regionEnum;

  // Helper getters
  bool get hasExactDate => date != null;
  bool get hasHumanReadableDate => human != null && human!.isNotEmpty;
  bool get hasYear => year != null;
  bool get hasMonth => month != null;
  bool get isAssociatedWithGame => gameId != null;
  bool get isAssociatedWithPlatform => platformId != null;
  bool get hasRegion => releaseRegionId != null || regionEnum != null;
  bool get hasStatus => statusId != null;

  // Release status helpers
  bool get isReleased {
    if (date == null) return false;
    return date!.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    if (date == null) return false;
    return date!.isAfter(DateTime.now());
  }

  bool get isReleasingToday {
    if (date == null) return false;
    final today = DateTime.now();
    final releaseDate = date!;
    return releaseDate.year == today.year &&
        releaseDate.month == today.month &&
        releaseDate.day == today.day;
  }

  // Time calculations
  Duration? get timeUntilRelease {
    if (date == null || isReleased) return null;
    return date!.difference(DateTime.now());
  }

  Duration? get timeSinceRelease {
    if (date == null || isUpcoming) return null;
    return DateTime.now().difference(date!);
  }

  // Date format helpers
  bool get hasFullDate => categoryEnum == ReleaseDateCategory.yyyymmdd;
  bool get hasYearAndMonth => categoryEnum == ReleaseDateCategory.yyyymm;
  bool get hasYearOnly => categoryEnum == ReleaseDateCategory.yyyy;
  bool get isQuarterlyRelease => [
    ReleaseDateCategory.yyyyq1,
    ReleaseDateCategory.yyyyq2,
    ReleaseDateCategory.yyyyq3,
    ReleaseDateCategory.yyyyq4,
  ].contains(categoryEnum);
  bool get isTbd => categoryEnum == ReleaseDateCategory.tbd;

  String get quarterDisplayName {
    switch (categoryEnum) {
      case ReleaseDateCategory.yyyyq1: return 'Q1 $year';
      case ReleaseDateCategory.yyyyq2: return 'Q2 $year';
      case ReleaseDateCategory.yyyyq3: return 'Q3 $year';
      case ReleaseDateCategory.yyyyq4: return 'Q4 $year';
      default: return '';
    }
  }

  // Display helpers
  String get displayDate {
    if (human != null && human!.isNotEmpty) {
      return human!;
    }

    if (isQuarterlyRelease) {
      return quarterDisplayName;
    }

    if (date != null) {
      if (hasFullDate) {
        return '${date!.day}/${date!.month}/${date!.year}';
      } else if (hasYearAndMonth) {
        return '${date!.month}/${date!.year}';
      } else if (hasYearOnly) {
        return '${date!.year}';
      }
    }

    if (year != null) {
      if (month != null) {
        return '$month/$year';
      }
      return '$year';
    }

    return 'TBD';
  }

  String get regionDisplayName {
    if (regionEnum != null) {
      return regionEnum!.displayName;
    }
    return 'Unknown Region';
  }

  @override
  List<Object?> get props => [
    id,
    checksum,
    createdAt,
    updatedAt,
    date,
    human,
    month,
    year,
    gameId,
    platformId,
    dateFormatId,
    releaseRegionId,
    statusId,
    categoryEnum,
    regionEnum,
  ];
}

