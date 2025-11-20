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
    var age = now.year - birthDate.year;

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

  // ==========================================
  // EVENT-SPECIFIC DATE FORMATTING
  // ==========================================

  /// Format event date for display in cards and lists
  static String formatEventDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    // If event is today
    if (isSameDay(date, now)) {
      return 'Today at ${_formatTime(date)}';
    }

    // If event is tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    if (isSameDay(date, tomorrow)) {
      return 'Tomorrow at ${_formatTime(date)}';
    }

    // If event is yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (isSameDay(date, yesterday)) {
      return 'Yesterday at ${_formatTime(date)}';
    }

    // If event is within this week
    if (difference.inDays.abs() <= 7) {
      final dayName = _getDayName(date.weekday);
      return '$dayName at ${_formatTime(date)}';
    }

    // If event is within this year
    if (date.year == now.year) {
      return '${_getMonthName(date.month)} ${date.day} at ${_formatTime(date)}';
    }

    // Full date with year
    return '${_getMonthName(date.month)} ${date.day}, ${date.year} at ${_formatTime(date)}';
  }

  /// Format event date and time for detailed views
  static String formatEventDateTime(DateTime date) {
    final dayName = _getDayName(date.weekday);
    final monthName = _getMonthName(date.month);
    final time = _formatTime(date);

    return '$dayName, $monthName ${date.day}, ${date.year} at $time';
  }

  /// Format event time range (start - end)
  static String formatEventTimeRange(DateTime start, DateTime? end) {
    if (end == null) {
      return 'Starts ${formatEventDate(start)}';
    }

    _formatTime(start);
    final endTime = _formatTime(end);

    // Same day event
    if (isSameDay(start, end)) {
      return '${formatEventDate(start)} - $endTime';
    }

    // Multi-day event
    return '${formatEventDate(start)} - ${formatEventDate(end)}';
  }

  /// Format event duration for display
  static String formatEventDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);

    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;

      if (hours == 0) {
        return '$days day${days == 1 ? '' : 's'}';
      } else {
        return '$days day${days == 1 ? '' : 's'} ${hours}h';
      }
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;

      if (minutes == 0) {
        return '$hours hour${hours == 1 ? '' : 's'}';
      } else {
        return '${hours}h ${minutes}m';
      }
    } else {
      final minutes = duration.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    }
  }

  /// Format time remaining until event starts
  static String formatTimeUntilEvent(DateTime eventTime) {
    final now = DateTime.now();
    final timeUntil = eventTime.difference(now);

    if (timeUntil.isNegative) {
      return 'Event has started';
    }

    if (timeUntil.inDays > 0) {
      final days = timeUntil.inDays;
      final hours = timeUntil.inHours % 24;

      if (hours == 0) {
        return 'in $days day${days == 1 ? '' : 's'}';
      } else {
        return 'in $days day${days == 1 ? '' : 's'} ${hours}h';
      }
    } else if (timeUntil.inHours > 0) {
      final hours = timeUntil.inHours;
      final minutes = timeUntil.inMinutes % 60;

      if (minutes == 0) {
        return 'in $hours hour${hours == 1 ? '' : 's'}';
      } else {
        return 'in ${hours}h ${minutes}m';
      }
    } else if (timeUntil.inMinutes > 0) {
      final minutes = timeUntil.inMinutes;
      return 'in $minutes minute${minutes == 1 ? '' : 's'}';
    } else {
      return 'starting now';
    }
  }

  /// Format time remaining during live event
  static String formatTimeRemainingInEvent(DateTime endTime) {
    final now = DateTime.now();
    final timeLeft = endTime.difference(now);

    if (timeLeft.isNegative) {
      return 'Event ended';
    }

    if (timeLeft.inHours > 0) {
      final hours = timeLeft.inHours;
      final minutes = timeLeft.inMinutes % 60;

      if (minutes == 0) {
        return '$hours hour${hours == 1 ? '' : 's'} left';
      } else {
        return '${hours}h ${minutes}m left';
      }
    } else if (timeLeft.inMinutes > 0) {
      final minutes = timeLeft.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} left';
    } else {
      return 'ending soon';
    }
  }

  /// Format event status with time context
  static String formatEventStatus(DateTime? startTime, DateTime? endTime) {
    final now = DateTime.now();

    if (startTime == null) {
      return 'Time TBA';
    }

    // Event hasn't started yet
    if (startTime.isAfter(now)) {
      return 'Starts ${formatTimeUntilEvent(startTime)}';
    }

    // Event is currently happening
    if (endTime != null && endTime.isAfter(now)) {
      return 'Live • ${formatTimeRemainingInEvent(endTime)}';
    }

    // Event has ended
    return 'Ended ${formatTimeAgo(endTime ?? startTime)}';
  }

  /// Format event time for compact display (cards, chips)
  static String formatEventTimeCompact(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    // If today
    if (isSameDay(date, now)) {
      return 'Today ${_formatTime(date)}';
    }

    // If tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    if (isSameDay(date, tomorrow)) {
      return 'Tomorrow ${_formatTime(date)}';
    }

    // If within a week
    if (difference.inDays.abs() <= 7) {
      return '${_getDayNameShort(date.weekday)} ${_formatTime(date)}';
    }

    // If this year
    if (date.year == now.year) {
      return '${_getMonthNameShort(date.month)} ${date.day}';
    }

    // With year
    return '${_getMonthNameShort(date.month)} ${date.day}, ${date.year}';
  }

  /// Format live event indicator
  static String formatLiveEventIndicator(
      DateTime startTime, DateTime? endTime,) {
    final now = DateTime.now();

    if (endTime != null && endTime.isAfter(now) && startTime.isBefore(now)) {
      final timeLeft = endTime.difference(now);

      if (timeLeft.inHours > 0) {
        return 'LIVE • ${timeLeft.inHours}h left';
      } else if (timeLeft.inMinutes > 0) {
        return 'LIVE • ${timeLeft.inMinutes}m left';
      } else {
        return 'LIVE • ending soon';
      }
    }

    return 'LIVE';
  }

  // ==========================================
  // HELPER METHODS FOR EVENTS
  // ==========================================

  static String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$displayHour:$minute $period';
  }

  static String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  static String _getDayNameShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  static String _getMonthNameShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // ==========================================
  // EVENT CALENDAR HELPERS
  // ==========================================

  /// Format date for event calendar headers
  static String formatCalendarDate(DateTime date) {
    final now = DateTime.now();

    if (isSameDay(date, now)) {
      return 'Today';
    }

    final tomorrow = now.add(const Duration(days: 1));
    if (isSameDay(date, tomorrow)) {
      return 'Tomorrow';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (isSameDay(date, yesterday)) {
      return 'Yesterday';
    }

    if (date.year == now.year) {
      return '${_getMonthName(date.month)} ${date.day}';
    }

    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  /// Format month and year for calendar headers
  static String formatCalendarMonthYear(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  /// Check if event spans multiple days
  static bool isMultiDayEvent(DateTime start, DateTime? end) {
    if (end == null) return false;
    return !isSameDay(start, end);
  }

  /// Get event duration in a human readable format
  static String getEventDurationDescription(DateTime start, DateTime? end) {
    if (end == null) {
      return 'Duration TBA';
    }

    if (isSameDay(start, end)) {
      return 'Single day event';
    }

    final duration = end.difference(start);
    final days = duration.inDays + 1; // Include both start and end days

    return '$days day event';
  }
}
