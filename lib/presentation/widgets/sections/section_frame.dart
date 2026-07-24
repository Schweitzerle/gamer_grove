import 'package:flutter/material.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';

/// Card shell shared by every Grove section: icon, title, subtitle, optional
/// "View All" action, then the section's own content.
///
/// Extracted from `BaseGameSection` so sections that are not game lists (e.g.
/// collections) look identical without duplicating the layout.
class SectionFrame extends StatelessWidget {
  const SectionFrame({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.onViewAll,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  /// Renders the "View All" action when non-null.
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
        ),
        color: theme.colorScheme.surface,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onViewAll != null)
                      TextButton(
                        onPressed: onViewAll,
                        child: const Text('View All'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
