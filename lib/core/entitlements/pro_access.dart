import 'package:flutter/widgets.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/injection_container.dart';

/// Convenience access to the current entitlement state from any widget.
extension EntitlementContext on BuildContext {
  /// Whether the signed-in user currently has GamerGrove Pro.
  bool get isPro => sl<EntitlementService>().entitlements.isPro;
}

/// Ensures the user has Pro before running a gated action.
///
/// Returns true if the user is already Pro. Otherwise it opens the paywall
/// (tagged with [source]) and returns whether the user is Pro *after* it
/// closes — i.e. true when they just purchased. Callers should guard
/// `context.mounted` after awaiting.
Future<bool> requirePro(
  BuildContext context, {
  required String source,
}) async {
  final service = sl<EntitlementService>();
  if (service.entitlements.isPro) return true;
  await Navigations.navigateToPaywall(context, source: source);
  return sl<EntitlementService>().entitlements.isPro;
}
