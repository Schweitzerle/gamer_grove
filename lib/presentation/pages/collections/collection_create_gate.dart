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
/// Server-side enforcement of the limit is a tracked follow-up; today the cap
/// lives here.
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

/// Fires the `collection_create` funnel event (fire-and-forget).
void trackCollectionCreate() {
  unawaited(sl<AnalyticsService>().track(AnalyticsEvents.collectionCreate));
}
