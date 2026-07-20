import 'dart:async';

import 'package:gamer_grove/core/entitlements/entitlements.dart';
import 'package:gamer_grove/core/entitlements/pro_feature.dart';

/// Abstraction over the subscription/entitlement backend.
///
/// The app depends on this interface, never on a concrete provider (currently
/// RevenueCat), so the billing backend can be swapped without touching feature
/// gates. Implementations MUST be safe to call before any purchase flow — the
/// default state is always the free tier.
abstract interface class EntitlementService {
  /// The current entitlement snapshot (never null; defaults to free).
  Entitlements get entitlements;

  /// Emits a new snapshot whenever entitlements change (purchase, restore,
  /// expiry, or a backend refresh).
  Stream<Entitlements> get changes;

  /// Whether [feature] is unlocked for the current user.
  bool has(ProFeature feature);

  /// Re-checks entitlements with the backend (e.g. on app resume / after a
  /// purchase). No-op for backends without a remote source.
  Future<void> refresh();

  /// Releases any resources (stream controllers, listeners).
  Future<void> dispose();
}

/// Entitlement service used when no billing backend is configured (e.g. in CI,
/// tests, or before a RevenueCat key is provided). Everyone is on the free
/// tier and every Pro gate is closed — the app stays fully functional.
class FreeEntitlementService implements EntitlementService {
  FreeEntitlementService();

  static const Entitlements _free = Entitlements.free();

  @override
  Entitlements get entitlements => _free;

  @override
  Stream<Entitlements> get changes => Stream<Entitlements>.value(_free);

  @override
  bool has(ProFeature feature) => _free.has(feature);

  @override
  Future<void> refresh() async {}

  @override
  Future<void> dispose() async {}
}
