import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
import 'package:gamer_grove/core/entitlements/pro_plan.dart';
import 'package:gamer_grove/core/services/toast_service.dart';
import 'package:gamer_grove/presentation/pages/paywall/widgets/pro_plan_card.dart';

/// Result of a purchase attempt triggered from the paywall.
typedef PurchaseHandler = Future<bool> Function(ProPlan plan);

/// Restores previous purchases; returns whether Pro is active afterwards.
typedef RestoreHandler = Future<bool> Function();

/// The GamerGrove Pro upgrade screen.
///
/// Presentation-only: it renders the value proposition and plans, fires the
/// funnel events (`paywall_view`, `purchase_start`, `purchase_done`) and
/// delegates the actual billing to [onPurchase]. When [onPurchase] is null
/// (billing not configured yet) the CTA still tracks intent and tells the user
/// subscriptions are coming soon — so the screen is fully functional pre-RevenueCat.
class PaywallPage extends StatefulWidget {
  const PaywallPage({
    required this.analytics,
    this.source = 'unknown',
    this.onPurchase,
    this.onRestore,
    super.key,
  });

  final AnalyticsService analytics;

  /// Where the paywall was opened from (tracked with `paywall_view`).
  final String source;

  /// Billing callback; null until RevenueCat is wired in.
  final PurchaseHandler? onPurchase;

  /// Restore-purchases callback; null until RevenueCat is wired in.
  final RestoreHandler? onRestore;

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  static const _features = <(IconData, String, String)>[
    (
      Icons.insights,
      'Deep stats & insights',
      'Genre, platform & rating trends'
    ),
    (
      Icons.collections_bookmark,
      'Unlimited collections',
      'Organize your library without limits'
    ),
    (Icons.tune, 'Advanced filters & sorting', 'Find exactly what you want'),
    (Icons.palette, 'Profile customization', 'Themes & badges that are yours'),
  ];

  ProPlan _selected = ProPlans.yearly;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      widget.analytics.track(
        AnalyticsEvents.paywallView,
        properties: {AnalyticsProps.source: widget.source},
      ),
    );
  }

  Future<void> _onPurchasePressed() async {
    if (_purchasing) return;
    await widget.analytics.track(
      AnalyticsEvents.purchaseStart,
      properties: {AnalyticsProps.plan: _selected.id},
    );

    final handler = widget.onPurchase;
    if (handler == null) {
      if (!mounted) return;
      GamerGroveToastService.showInfo(
        context,
        title: 'Coming soon',
        message: "Subscriptions aren't available just yet.",
      );
      return;
    }

    setState(() => _purchasing = true);
    final success = await handler(_selected);
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (success) {
      await widget.analytics.track(
        AnalyticsEvents.purchaseDone,
        properties: {AnalyticsProps.plan: _selected.id},
      );
      if (!mounted) return;
      GamerGroveToastService.showSuccess(
        context,
        title: 'Welcome to GamerGrove Pro!',
        message: 'Your Pro features are now unlocked.',
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _onRestorePressed() async {
    final handler = widget.onRestore;
    if (handler == null) return;
    final restored = await handler();
    if (!mounted) return;
    if (restored) {
      GamerGroveToastService.showSuccess(
        context,
        title: 'Purchases restored',
        message: 'Your GamerGrove Pro is active again.',
      );
      Navigator.of(context).pop(true);
    } else {
      GamerGroveToastService.showInfo(
        context,
        title: 'Nothing to restore',
        message: 'We found no previous Pro purchase for this account.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _ProHero(),
                    const SizedBox(height: 28),
                    for (final f in _features) ...[
                      _FeatureRow(icon: f.$1, title: f.$2, subtitle: f.$3),
                      const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 10),
                    for (final plan in ProPlans.all) ...[
                      ProPlanCard(
                        plan: plan,
                        selected: _selected == plan,
                        onTap: () => setState(() => _selected = plan),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            _PaywallFooter(
              purchasing: _purchasing,
              onPurchase: _onPurchasePressed,
              onRestore: widget.onRestore != null ? _onRestorePressed : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProHero extends StatelessWidget {
  const _ProHero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.workspace_premium, size: 56, color: scheme.onPrimary),
          const SizedBox(height: 12),
          Text(
            'GamerGrove Pro',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Level up your gaming life',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaywallFooter extends StatelessWidget {
  const _PaywallFooter({
    required this.purchasing,
    required this.onPurchase,
    this.onRestore,
  });

  final bool purchasing;
  final VoidCallback onPurchase;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: purchasing ? null : onPurchase,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: purchasing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start GamerGrove Pro'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cancel anytime. Auto-renews until cancelled.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          if (onRestore != null)
            TextButton(
              onPressed: purchasing ? null : onRestore,
              child: const Text('Restore purchases'),
            ),
        ],
      ),
    );
  }
}
