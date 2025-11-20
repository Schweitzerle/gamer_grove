import 'package:flutter/material.dart';

class LeaderboardRank extends StatelessWidget {

  const LeaderboardRank({required this.rank, super.key});
  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getRankColor(rank);
    final textStyle = theme.textTheme.titleLarge?.copyWith(
      color: color,
      fontWeight: FontWeight.bold,
    );

    return Container(
      width: 50,
      alignment: Alignment.center,
      child: Text(
        '#$rank',
        style: textStyle,
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }
}
