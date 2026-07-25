import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/entitlements/free_limits.dart';
import 'package:gamer_grove/core/entitlements/pro_access.dart';
import 'package:gamer_grove/core/services/toast_service.dart';
import 'package:gamer_grove/injection_container.dart';

/// Gate shared by every "create collection" entry point.
///
/// Free users may create up to [kFreeCollectionLimit] collections; at the cap
/// this opens the paywall (source `collections_limit`) and returns whether the
/// user may proceed (true when already Pro, under the limit, or just upgraded).
///
/// This is the fast path only — the database enforces the same cap
/// (SupabaseScripts/014), so a bypassed client is still rejected. Use
/// [handleServerCollectionLimit] to handle that server-side rejection.
Future<bool> ensureCanCreateCollection(
  BuildContext context,
  int currentCount,
) async {
  final blocked = isAtFreeCollectionLimit(
    isPro: context.isPro,
    currentCount: currentCount,
  );
  if (!blocked) return true;
  return requirePro(context, source: 'collections_limit');
}

/// Handles a create that the database rejected for exceeding the free limit.
///
/// Two very different situations end up here, and neither may end silently:
/// a free user who bypassed the local gate gets the paywall, while a user the
/// client already considers Pro has a state mismatch — their subscription has
/// not reached the database yet (webhook in flight, or the purchase was never
/// linked to the account). Showing the paywall to someone who just paid would
/// be absurd, and `requirePro` would return instantly without any UI at all.
Future<ServerLimitOutcome> handleServerCollectionLimit(
  BuildContext context,
) async {
  if (decideServerLimitOutcome(isPro: context.isPro) ==
      ServerLimitOutcome.upgradeOffered) {
    await requirePro(context, source: 'collections_limit_server');
    return ServerLimitOutcome.upgradeOffered;
  }

  // Pull the entitlement state again; the mismatch is often transient.
  await sl<EntitlementService>().refresh();
  if (!context.mounted) return ServerLimitOutcome.mismatchReported;
  GamerGroveToastService.showError(
    context,
    title: "Couldn't create the collection",
    message: 'Your Pro subscription has not reached our servers yet. '
        'Please try again in a moment.',
  );
  return ServerLimitOutcome.mismatchReported;
}

/// The rule behind [handleServerCollectionLimit], free of UI so it can be
/// tested directly: only a user the client does not consider Pro should ever be
/// shown the paywall after a server-side rejection.
ServerLimitOutcome decideServerLimitOutcome({required bool isPro}) => isPro
    ? ServerLimitOutcome.mismatchReported
    : ServerLimitOutcome.upgradeOffered;

/// Which branch [handleServerCollectionLimit] took. Callers may ignore it; it
/// makes the decision observable instead of hiding inside a void function.
enum ServerLimitOutcome {
  /// The user is not Pro and was shown the paywall.
  upgradeOffered,

  /// The user is Pro but the server disagreed; they were told so.
  mismatchReported,
}

/// Fires the `collection_create` funnel event (fire-and-forget).
void trackCollectionCreate() {
  unawaited(sl<AnalyticsService>().track(AnalyticsEvents.collectionCreate));
}
