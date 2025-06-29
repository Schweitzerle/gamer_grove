// lib/domain/entities/date_format.dart
import 'package:equatable/equatable.dart';

class DateFormat extends Equatable {
  final int id;
  final String checksum;
  final String format;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DateFormat({
    required this.id,
    required this.checksum,
    required this.format,
    this.createdAt,
    this.updatedAt,
  });

  // Helper method to get human-readable format description
  String get description {
    switch (format) {
      case 'YYYYMMMMDD':
        return 'Full Date (e.g., 2024-12-25)';
      case 'YYYYMMMM':
        return 'Month and Year (e.g., December 2024)';
      case 'YYYY':
        return 'Year Only (e.g., 2024)';
      case 'YYYYQ1':
        return 'Q1 Year (e.g., Q1 2024)';
      case 'YYYYQ2':
        return 'Q2 Year (e.g., Q2 2024)';
      case 'YYYYQ3':
        return 'Q3 Year (e.g., Q3 2024)';
      case 'YYYYQ4':
        return 'Q4 Year (e.g., Q4 2024)';
      case 'TBD':
        return 'To Be Determined';
      default:
        return format;
    }
  }

  // Helper to check precision level
  bool get isExactDate => format == 'YYYYMMMMDD';
  bool get isMonthPrecision => format == 'YYYYMMMM';
  bool get isYearPrecision => format == 'YYYY';
  bool get isQuarterPrecision => format.startsWith('YYYYQ');
  bool get isTBD => format == 'TBD';

  @override
  List<Object?> get props => [
    id,
    checksum,
    format,
    createdAt,
    updatedAt,
  ];
}

// Date Format Category Enum (für Legacy Support)
enum DateFormatCategory {
  yyyyMMMMdd(0),
  yyyyMMMM(1),
  yyyy(2),
  yyyyQ1(3),
  yyyyQ2(4),
  yyyyQ3(5),
  yyyyQ4(6),
  tbd(7);

  const DateFormatCategory(this.value);
  final int value;

  static DateFormatCategory fromValue(int value) {
    return values.firstWhere(
          (category) => category.value == value,
      orElse: () => tbd,
    );
  }

  String get format {
    switch (this) {
      case yyyyMMMMdd: return 'YYYYMMMMDD';
      case yyyyMMMM: return 'YYYYMMMM';
      case yyyy: return 'YYYY';
      case yyyyQ1: return 'YYYYQ1';
      case yyyyQ2: return 'YYYYQ2';
      case yyyyQ3: return 'YYYYQ3';
      case yyyyQ4: return 'YYYYQ4';
      case tbd: return 'TBD';
    }
  }
}