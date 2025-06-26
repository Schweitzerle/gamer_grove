// core/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  // Date formats
  static const String _fullDateFormat = 'MMMM dd, yyyy';
  static const String _shortDateFormat = 'MMM dd, yyyy';
  static const String _yearOnlyFormat = 'yyyy';
  static const String _monthYearFormat = 'MMMM yyyy';
  static const String _timeFormat = 'HH:mm';
  static const String _dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Formatters
  static final DateFormat _fullFormatter = DateFormat(_fullDateFormat);
  static final DateFormat _shortFormatter = DateFormat(_shortDateFormat);
  static final DateFormat _yearFormatter = DateFormat(_yearOnlyFormat);
  static final DateFormat _monthYearFormatter = DateFormat(_monthYearFormat);
  static final DateFormat _timeFormatter = DateFormat(_timeFormat);
  static final DateFormat _dateTimeFormatter = DateFormat(_dateTimeFormat);

  // Format methods
  static String formatFullDate(DateTime date) {
    return _fullFormatter.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _shortFormatter.format(date);
  }

  static String formatYearOnly(DateTime date) {
    return _yearFormatter.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormatter.format(date);
  }

  // Relative time formatting
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Game release date formatting
  static String formatGameReleaseDate(DateTime? releaseDate) {
    if (releaseDate == null) return 'TBA';

    final now = DateTime.now();

    if (releaseDate.isAfter(now)) {
      // Future release
      return 'Releasing ${formatShortDate(releaseDate)}';
    } else {
      // Already released
      return 'Released ${formatShortDate(releaseDate)}';
    }
  }

  // Parse dates safely
  static DateTime? tryParseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Check if date is in the future
  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    // Add a small buffer (1 day) to account for timezone differences
    return date.isAfter(now.add(const Duration(days: 1)));
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Get age from birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '${months}mo ago';
    } else {
      return formatShortDate(date);
    }
  }

  static String formatRelativeReleaseDate(DateTime releaseDate) {
    final now = DateTime.now();
    final difference = releaseDate.difference(now);

    if (difference.isNegative) {
      // Game already released
      final pastDifference = now.difference(releaseDate);
      if (pastDifference.inDays < 30) {
        return 'Released ${pastDifference.inDays} days ago';
      } else if (pastDifference.inDays < 365) {
        final months = pastDifference.inDays ~/ 30;
        return 'Released $months months ago';
      } else {
        return 'Released ${formatYearOnly(releaseDate)}';
      }
    } else {
      // Game not yet released
      if (difference.inDays < 30) {
        return 'Releases in ${difference.inDays} days';
      } else if (difference.inDays < 365) {
        final months = difference.inDays ~/ 30;
        return 'Releases in $months months';
      } else {
        return 'Releases ${formatYearOnly(releaseDate)}';
      }
    }
  }

  static bool isUpcoming(DateTime? releaseDate) {
    if (releaseDate == null) return false;
    return releaseDate.isAfter(DateTime.now());
  }

  static bool isRecentlyReleased(DateTime? releaseDate) {
    if (releaseDate == null) return false;
    final now = DateTime.now();
    final difference = now.difference(releaseDate);
    return !difference.isNegative && difference.inDays <= 30;
  }
}
