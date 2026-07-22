/// Canonical analytics event names for the conversion + engagement funnel.
///
/// Keep every tracked event name here so the schema is discoverable and stable
/// (renaming an event breaks historical reports). Names are snake_case.
///
/// Funnel: app_open -> signup -> activation -> (rate_game / wishlist_add /
/// follow_user) -> paywall_view -> purchase_start -> purchase_done.
abstract final class AnalyticsEvents {
  /// App launched / brought to foreground.
  static const String appOpen = 'app_open';

  /// A new account was created.
  static const String signup = 'signup';

  /// User reached the core-value moment (see MASTERPLAN Phase 3 activation
  /// definition). Emit exactly once per user when the condition is first met.
  static const String activation = 'activation';

  /// User rated a game.
  static const String rateGame = 'rate_game';

  /// User added a game to their wishlist.
  static const String wishlistAdd = 'wishlist_add';

  /// User followed another user.
  static const String followUser = 'follow_user';

  /// User created a custom collection.
  static const String collectionCreate = 'collection_create';

  /// The paywall / upgrade screen was shown.
  static const String paywallView = 'paywall_view';

  /// User started a purchase (tapped a subscription option).
  static const String purchaseStart = 'purchase_start';

  /// A purchase completed successfully.
  static const String purchaseDone = 'purchase_done';

  /// A screen was viewed (pass `screen` name in properties).
  static const String screenView = 'screen_view';
}

/// Common property keys used across events (keeps property naming consistent).
abstract final class AnalyticsProps {
  static const String gameId = 'game_id';
  static const String rating = 'rating';
  static const String screen = 'screen';
  static const String plan = 'plan';
  static const String source = 'source';
}
