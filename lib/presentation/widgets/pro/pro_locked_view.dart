import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/navigations.dart';

/// Full-surface placeholder shown in place of a Pro-only feature for free
/// users. Explains the feature and offers a single upgrade CTA into the paywall.
class ProLockedView extends StatelessWidget {
  const ProLockedView({
    required this.title,
    required this.description,
    required this.source,
    super.key,
    this.icon = Icons.workspace_premium,
  });

  /// Short name of the locked feature, e.g. "Gaming statistics".
  final String title;

  /// One line on what the user unlocks.
  final String description;

  /// Analytics source tag passed to the paywall (`paywall_view`).
  final String source;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.tertiary],
                ),
              ),
              child: Icon(icon, size: 44, color: scheme.onPrimary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Pro feature',
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  Navigations.navigateToPaywall(context, source: source),
              icon: const Icon(Icons.workspace_premium),
              label: const Text('Unlock with GamerGrove Pro'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
