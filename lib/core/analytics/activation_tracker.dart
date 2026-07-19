import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fires the one-time `activation` funnel event when the user first reaches the
/// core-value moment.
///
/// Activation condition (MASTERPLAN Phase 3): the user has **rated their first
/// game**, OR has **wishlisted at least 3 games AND followed at least 1 user**.
///
/// The event must be emitted exactly once per user/device. State is persisted
/// in [SharedPreferences] so a relaunch never re-fires it. Signals arrive from
/// several BLoCs (rating, wishlist, follow), so this is a shared singleton
/// rather than per-bloc state.
class ActivationTracker {
  ActivationTracker({
    required AnalyticsService analytics,
    required SharedPreferences prefs,
  })  : _analytics = analytics,
        _prefs = prefs;

  final AnalyticsService _analytics;
  final SharedPreferences _prefs;

  static const String _kActivated = 'activation_fired';
  static const String _kWishlistCount = 'activation_wishlist_count';
  static const String _kFollowCount = 'activation_follow_count';

  /// Wishlist adds required (with at least one follow) to activate.
  static const int _wishlistThreshold = 3;

  /// Whether activation has already been recorded for this device.
  bool get hasActivated => _prefs.getBool(_kActivated) ?? false;

  /// Signal that the user rated a game. Rating a first game activates directly.
  Future<void> onGameRated() => _maybeActivate(ratedNow: true);

  /// Signal that the user added a game to their wishlist.
  Future<void> onWishlistAdded() async {
    if (hasActivated) return;
    final next = (_prefs.getInt(_kWishlistCount) ?? 0) + 1;
    await _prefs.setInt(_kWishlistCount, next);
    await _maybeActivate();
  }

  /// Signal that the user followed another user.
  Future<void> onUserFollowed() async {
    if (hasActivated) return;
    final next = (_prefs.getInt(_kFollowCount) ?? 0) + 1;
    await _prefs.setInt(_kFollowCount, next);
    await _maybeActivate();
  }

  Future<void> _maybeActivate({bool ratedNow = false}) async {
    if (hasActivated) return;

    final wishlistCount = _prefs.getInt(_kWishlistCount) ?? 0;
    final followCount = _prefs.getInt(_kFollowCount) ?? 0;
    final activated =
        ratedNow || (wishlistCount >= _wishlistThreshold && followCount >= 1);
    if (!activated) return;

    await _prefs.setBool(_kActivated, true);
    await _analytics.track(AnalyticsEvents.activation);
  }
}
