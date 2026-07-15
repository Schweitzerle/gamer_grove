import 'package:flutter/foundation.dart';

/// Abstraction over the analytics backend.
///
/// The app depends on this interface, never on a concrete provider, so the
/// backend (currently Umami) can be swapped without touching call sites.
/// Implementations MUST be fire-and-forget safe: analytics must never throw
/// into product code or block the UI.
abstract interface class AnalyticsService {
  /// Records an event. [name] should come from `AnalyticsEvents`.
  Future<void> track(String name, {Map<String, Object?>? properties});

  /// Convenience for screen-view tracking.
  Future<void> screen(String screenName);
}

/// No-op analytics used when no backend is configured (e.g. in CI, tests, or
/// when the Umami URL is empty). Keeps the app fully functional without keys.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> track(String name, {Map<String, Object?>? properties}) async {
    if (kDebugMode) {
      debugPrint('[analytics:noop] $name ${properties ?? const {}}');
    }
  }

  @override
  Future<void> screen(String screenName) async {
    if (kDebugMode) {
      debugPrint('[analytics:noop] screen $screenName');
    }
  }
}
