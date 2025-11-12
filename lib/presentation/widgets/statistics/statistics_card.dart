import 'package:flutter/material.dart';

/// A card widget for displaying statistics
class StatisticsCard extends StatefulWidget {

  /// Creates a StatisticsCard
  const StatisticsCard({
    required this.title,
    required this.child,
    super.key,
    this.icon,
    this.backgroundColor,
    this.collapsible = false,
    this.initiallyCollapsed = false,
  });
  /// Title of the statistics card
  final String title;

  /// Child widget to display
  final Widget child;

  /// Icon to display in the header
  final IconData? icon;

  /// Background color
  final Color? backgroundColor;

  /// Whether the card can be expanded/collapsed
  final bool collapsible;

  /// Initial collapsed state
  final bool initiallyCollapsed;

  @override
  State<StatisticsCard> createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.collapsible
                ? () => setState(() => _isCollapsed = !_isCollapsed)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.collapsible)
                    Icon(
                      _isCollapsed
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                ],
              ),
            ),
          ),
          if (!_isCollapsed) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),
          ],
        ],
      ),
    );
  }
}
