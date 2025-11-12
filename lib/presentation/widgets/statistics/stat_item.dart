import 'package:flutter/material.dart';

/// A single statistics item displaying a label, value, and optional percentage
class StatItem extends StatelessWidget {

  /// Creates a StatItem
  const StatItem({
    required this.label,
    required this.value,
    super.key,
    this.percentage,
    this.valueColor,
    this.showProgress = false,
  });
  /// Label for the stat
  final String label;

  /// Value to display
  final String value;

  /// Optional percentage value
  final double? percentage;

  /// Color for the value
  final Color? valueColor;

  /// Whether to show a progress bar
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveValueColor = valueColor ?? theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: effectiveValueColor,
                ),
              ),
              if (percentage != null) ...[
                const SizedBox(width: 8),
                Text(
                  '${percentage!.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
          if (showProgress && percentage != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage! / 100,
                minHeight: 6,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(effectiveValueColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
