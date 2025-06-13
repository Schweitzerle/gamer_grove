// lib/presentation/widgets/top_three_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game.dart';
import '../blocs/game/game_bloc.dart';

class TopThreeDialog extends StatefulWidget {
  final Game game;
  final String userId;
  final List<int> currentTopThree; // Current top three games

  const TopThreeDialog({
    super.key,
    required this.game,
    required this.userId,
    required this.currentTopThree,
  });

  @override
  State<TopThreeDialog> createState() => _TopThreeDialogState();
}

class _TopThreeDialogState extends State<TopThreeDialog> {
  int selectedPosition = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 8),
          const Text('Add to Top 3'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add "${widget.game.name}" to your top 3 games?'),
          const SizedBox(height: 16),

          // Position Selection
          Text(
            'Select position:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Position Options
          Column(
            children: [
              for (int i = 1; i <= 3; i++)
                RadioListTile<int>(
                  value: i,
                  groupValue: selectedPosition,
                  onChanged: (value) {
                    setState(() {
                      selectedPosition = value!;
                    });
                  },
                  title: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getPositionColor(i),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$i',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getPositionText(i),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  subtitle: widget.currentTopThree.length >= i
                      ? Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      'Currently: Game ${widget.currentTopThree[i - 1]}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                      : null,
                  dense: true,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Info Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedPosition <= widget.currentTopThree.length
                        ? 'This will replace the current game at position $selectedPosition'
                        : 'This will add the game to position $selectedPosition',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            _addToTopThreeAtPosition(selectedPosition);
          },
          icon: const Icon(Icons.star),
          label: Text('Add to Position $selectedPosition'),
          style: FilledButton.styleFrom(
            backgroundColor: _getPositionColor(selectedPosition),
          ),
        ),
      ],
    );
  }

  void _addToTopThreeAtPosition(int position) {
    // Create new top three list
    final newTopThree = List<int>.from(widget.currentTopThree);

    // Remove the game if it already exists
    newTopThree.remove(widget.game.id);

    // Ensure list has enough elements
    while (newTopThree.length < 3) {
      newTopThree.add(0); // 0 as placeholder for empty slots
    }

    // Insert at the selected position
    newTopThree[position - 1] = widget.game.id;

    // Remove any 0 placeholders and keep only actual game IDs
    final finalTopThree = newTopThree.where((id) => id != 0).toList();

    // Add the event to BLoC
    context.read<GameBloc>().add(AddToTopThreeEvent(
      gameId: widget.game.id,
      userId: widget.userId,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${widget.game.name}" to position $position!'),
        backgroundColor: _getPositionColor(position),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber[700]!; // Gold
      case 2:
        return Colors.grey[600]!; // Silver
      case 3:
        return Colors.brown[600]!; // Bronze
      default:
        return Colors.grey;
    }
  }

  String _getPositionText(int position) {
    switch (position) {
      case 1:
        return 'Position 1 (Gold)';
      case 2:
        return 'Position 2 (Silver)';
      case 3:
        return 'Position 3 (Bronze)';
      default:
        return 'Position $position';
    }
  }
}