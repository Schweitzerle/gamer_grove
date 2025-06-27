// ==================================================
// STATISTICS SECTION
// ==================================================

// lib/presentation/pages/game_detail/widgets/sections/statistics_section.dart
import 'package:flutter/material.dart';
import '../../../../../domain/entities/game.dart';

class StatisticsSection extends StatelessWidget {
  final Game game;

  const StatisticsSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatItem(
          icon: Icons.star,
          label: 'IGDB Rating',
          value: game.rating?.toStringAsFixed(1) ?? 'N/A',
          color: Colors.amber,
        ),
        StatItem(
          icon: Icons.trending_up,
          label: 'Hype',
          value: game.hypes?.toStringAsFixed(0) ?? 'N/A',
          color: Colors.red,
        ),
      ],
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}