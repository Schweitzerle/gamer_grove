import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/entitlements/pro_feature.dart';

/// Immutable snapshot of what the current user is entitled to.
///
/// A single `GamerGrove Pro` subscription unlocks every [ProFeature]; this is
/// modelled as one [isPro] flag today, but [has] is the API call sites use so
/// per-feature gating can be introduced later without changing them.
class Entitlements extends Equatable {
  const Entitlements({required this.isPro});

  /// The default, no-subscription state: free tier.
  const Entitlements.free() : isPro = false;

  /// A fully-entitled Pro user.
  const Entitlements.pro() : isPro = true;

  /// Whether the user currently has an active Pro entitlement.
  final bool isPro;

  /// Whether the free tier is active (convenience inverse of [isPro]).
  bool get isFree => !isPro;

  /// Whether [feature] is unlocked for the current user.
  ///
  /// Today every Pro feature is unlocked by the single subscription; kept as a
  /// per-feature method so gating can become granular without call-site churn.
  bool has(ProFeature feature) => isPro;

  @override
  List<Object?> get props => [isPro];
}
