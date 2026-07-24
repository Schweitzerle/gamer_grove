import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
import 'package:gamer_grove/core/entitlements/free_limits.dart';
import 'package:gamer_grove/core/entitlements/pro_access.dart';
import 'package:gamer_grove/injection_container.dart';

/// Gate shared by every "create collection" entry point.
///
/// Free users may create up to [kFreeCollectionLimit] collections; at the cap
/// this opens the paywall (source `collections_limit`) and returns whether the
/// user may proceed (true when already Pro, under the limit, or just upgraded).
///
/// This is the fast path only — the database enforces the same cap
/// (SupabaseScripts/014), so a bypassed client is still rejected. Use
/// [showCollectionLimitPaywall] to handle that server-side rejection.
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

/// Opens the paywall after the database rejected a create for exceeding the
/// free limit — reached when the local count was stale or the gate was bypassed.
Future<void> showCollectionLimitPaywall(BuildContext context) async {
  await requirePro(context, source: 'collections_limit_server');
}

/// Fires the `collection_create` funnel event (fire-and-forget).
void trackCollectionCreate() {
  unawaited(sl<AnalyticsService>().track(AnalyticsEvents.collectionCreate));
}
