// ==================================================
// PERFORMANCE MONITORING
// ==================================================

// lib/core/utils/performance_monitor.dart
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, Duration> _durations = {};

  static void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
    print('⏱️ Started: $operation');
  }

  static void endTimer(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _durations[operation] = duration;
      print('✅ Completed: $operation in ${duration.inMilliseconds}ms');
      _startTimes.remove(operation);
    }
  }

  static void logAPICall(String endpoint, int statusCode, Duration duration) {
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    print('$emoji API: $endpoint -> $statusCode (${duration.inMilliseconds}ms)');
  }

  static Map<String, Duration> getCompletedOperations() {
    return Map.from(_durations);
  }

  static void reset() {
    _startTimes.clear();
    _durations.clear();
  }
}