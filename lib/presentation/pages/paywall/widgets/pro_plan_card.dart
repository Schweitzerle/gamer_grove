import 'package:flutter/material.dart';
import 'package:gamer_grove/core/entitlements/pro_plan.dart';

/// Selectable plan card used on the paywall.
///
/// Renders the price, billing period and optional highlight badge, with a
/// clearly designed selected/unselected state. The whole card is one tappable
/// button node for accessibility.
class ProPlanCard extends StatelessWidget {
  const ProPlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final ProPlan plan;
  final bool selected;
  final VoidCallback onTap;

  String get _periodLabel =>
      plan.period == ProBillingPeriod.yearly ? 'per year' : 'per month';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final borderColor = selected ? scheme.primary : scheme.outlineVariant;
    final background = selected
        ? scheme.primaryContainer.withValues(alpha: 0.35)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.4);

    return Semantics(
      button: true,
      selected: selected,
      label: '${plan.period == ProBillingPeriod.yearly ? 'Yearly' : 'Monthly'} '
          'plan, ${plan.priceLabel} $_periodLabel'
          '${plan.badge != null ? ', ${plan.badge}' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              _SelectionDot(selected: selected),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.priceLabel,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            _periodLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (plan.subLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        plan.subLabel!,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (plan.badge != null) _PlanBadge(label: plan.badge!),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? scheme.primary : scheme.outline,
          width: 2,
        ),
        color: selected ? scheme.primary : Colors.transparent,
      ),
      child: selected
          ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
          : null,
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onTertiaryContainer,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
      ),
    );
  }
}
