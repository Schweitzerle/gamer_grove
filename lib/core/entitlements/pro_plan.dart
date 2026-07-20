import 'package:equatable/equatable.dart';

/// Billing period of a [ProPlan].
enum ProBillingPeriod { monthly, yearly }

/// A purchasable GamerGrove Pro plan.
///
/// Prices are display strings today (the decided pricing: 2,99 €/month,
/// 19,99 €/year). Once RevenueCat is configured these are replaced by the
/// store's localized `priceString`s from the fetched offering — [id] maps to
/// the RevenueCat package identifier.
class ProPlan extends Equatable {
  const ProPlan({
    required this.id,
    required this.period,
    required this.priceLabel,
    this.badge,
    this.subLabel,
  });

  /// Stable identifier (maps to the RevenueCat package id later).
  final String id;

  final ProBillingPeriod period;

  /// Localized price string, e.g. `2,99 €`.
  final String priceLabel;

  /// Optional highlight badge, e.g. `Best value`.
  final String? badge;

  /// Optional secondary line, e.g. `Save 44% vs. monthly`.
  final String? subLabel;

  @override
  List<Object?> get props => [id, period, priceLabel, badge, subLabel];
}

/// The static default plans, used until RevenueCat offerings are wired in.
///
/// Decided pricing (PROGRESS.md): 2,99 €/month · 19,99 €/year.
/// 19,99 vs 12×2,99 (35,88) ≈ 44 % saving.
abstract final class ProPlans {
  static const ProPlan yearly = ProPlan(
    id: 'gg_pro_yearly',
    period: ProBillingPeriod.yearly,
    priceLabel: '19,99 €',
    badge: 'Best value',
    subLabel: 'Save 44% vs. monthly',
  );

  static const ProPlan monthly = ProPlan(
    id: 'gg_pro_monthly',
    period: ProBillingPeriod.monthly,
    priceLabel: '2,99 €',
  );

  /// Plans in display order (highlighted first).
  static const List<ProPlan> all = [yearly, monthly];
}
