import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/analytics/activation_tracker.dart';
import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records tracked event names so tests can assert on activation emission.
class _RecordingAnalytics implements AnalyticsService {
  final List<String> tracked = [];

  @override
  Future<void> track(String name, {Map<String, Object?>? properties}) async {
    tracked.add(name);
  }

  @override
  Future<void> screen(String screenName) async {}
}

void main() {
  late _RecordingAnalytics analytics;
  late SharedPreferences prefs;

  Future<ActivationTracker> buildTracker() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    analytics = _RecordingAnalytics();
    return ActivationTracker(analytics: analytics, prefs: prefs);
  }

  group('ActivationTracker', () {
    test('rating the first game activates immediately', () async {
      final tracker = await buildTracker();

      await tracker.onGameRated();

      expect(analytics.tracked, [AnalyticsEvents.activation]);
      expect(tracker.hasActivated, isTrue);
    });

    test('activation fires only once across repeated signals', () async {
      final tracker = await buildTracker();

      await tracker.onGameRated();
      await tracker.onGameRated();
      await tracker.onWishlistAdded();

      expect(
        analytics.tracked.where((e) => e == AnalyticsEvents.activation).length,
        1,
      );
    });

    test('3 wishlist adds without a follow do NOT activate', () async {
      final tracker = await buildTracker();

      await tracker.onWishlistAdded();
      await tracker.onWishlistAdded();
      await tracker.onWishlistAdded();

      expect(analytics.tracked, isEmpty);
      expect(tracker.hasActivated, isFalse);
    });

    test('a follow alone does NOT activate', () async {
      final tracker = await buildTracker();

      await tracker.onUserFollowed();

      expect(analytics.tracked, isEmpty);
      expect(tracker.hasActivated, isFalse);
    });

    test('3 wishlist adds + 1 follow activates', () async {
      final tracker = await buildTracker();

      await tracker.onWishlistAdded();
      await tracker.onWishlistAdded();
      await tracker.onUserFollowed();
      // Only two wishlist adds so far: still below threshold.
      expect(tracker.hasActivated, isFalse);

      await tracker.onWishlistAdded();

      expect(analytics.tracked, [AnalyticsEvents.activation]);
      expect(tracker.hasActivated, isTrue);
    });

    test('activation state survives a new tracker on the same prefs', () async {
      final tracker = await buildTracker();
      await tracker.onGameRated();
      expect(tracker.hasActivated, isTrue);

      // A fresh tracker reading the same persisted prefs must not re-fire.
      final freshAnalytics = _RecordingAnalytics();
      final freshTracker =
          ActivationTracker(analytics: freshAnalytics, prefs: prefs);

      await freshTracker.onGameRated();

      expect(freshTracker.hasActivated, isTrue);
      expect(freshAnalytics.tracked, isEmpty);
    });
  });
}
