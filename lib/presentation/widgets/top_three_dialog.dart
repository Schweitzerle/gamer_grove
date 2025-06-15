// top_three_dialog.dart - Korrigierte Version
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/game.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../../injection_container.dart';
import '../../data/datasources/remote/supabase_remote_datasource.dart';

class TopThreeDialog extends StatefulWidget {
  final Game game;
  final String userId;

  const TopThreeDialog({
    super.key,
    required this.game,
    required this.userId,
  });

  @override
  State<TopThreeDialog> createState() => _TopThreeDialogState();
}

class _TopThreeDialogState extends State<TopThreeDialog> {
  List<Game> _currentTopThree = [];
  List<int> _currentTopThreeIds = [];
  bool _isLoading = true;
  int? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _loadCurrentTopThree();
  }

  Future<void> _loadCurrentTopThree() async {
    try {
      // Lade die aktuellen Top 3 Game IDs mit Position
      final supabaseDataSource = sl<SupabaseRemoteDataSource>();
      final topThreeData = await supabaseDataSource.getTopThreeGamesWithPosition(widget.userId);

      // Extrahiere nur die game_ids in der richtigen Reihenfolge
      final topThreeIds = topThreeData
          .map<int>((item) => item['game_id'] as int)
          .toList();

      setState(() {
        _isLoading = false;
        _currentTopThreeIds = topThreeIds;
        // TODO: Hier könnten wir die Game Details laden wenn nötig
        // Vorerst zeigen wir nur die IDs
      });
    } catch (e) {
      print('Error loading top three: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add to Top 3',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.game.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Current Top 3 or Empty Slots
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select position to add or replace:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Position Slots
                  ...List.generate(3, (index) {
                    final position = index + 1;
                    final hasGame = _currentTopThreeIds.length > index;
                    final gameId = hasGame ? _currentTopThreeIds[index] : null;

                    return _buildPositionSlot(
                      position: position,
                      gameId: gameId,
                      isSelected: _selectedPosition == position,
                      onTap: () {
                        setState(() {
                          _selectedPosition = position;
                        });
                      },
                    );
                  }),
                ],
              ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _selectedPosition != null
                      ? () => _addToTopThree()
                      : null,
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionSlot({
    required int position,
    int? gameId,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Position Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getPositionColor(position),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$position',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Game Info or Empty Slot
            Expanded(
              child: gameId != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game ID: $gameId',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Current #$position',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
                  : Text(
                'Empty Slot',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            if (isSelected)
              Icon(
                Icons.swap_horiz,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[600]!;
      case 3:
        return Colors.brown[600]!;
      default:
        return Colors.grey;
    }
  }

  void _addToTopThree() async {
    if (_selectedPosition == null) return;

    try {
      // Erstelle neue Top 3 Liste
      final newTopThree = List<int>.from(_currentTopThreeIds);

      // Stelle sicher, dass die Liste mindestens so lang ist wie die Position
      while (newTopThree.length < _selectedPosition!) {
        newTopThree.add(0); // Temporärer Platzhalter
      }

      // Setze das neue Spiel an der gewählten Position
      newTopThree[_selectedPosition! - 1] = widget.game.id;

      // Entferne leere/null Einträge und limitiere auf 3
      final cleanedTopThree = newTopThree
          .where((id) => id != 0)
          .take(3)
          .toList();

      // Update in Supabase
      final supabaseDataSource = sl<SupabaseRemoteDataSource>();
      await supabaseDataSource.updateTopThreeGames(widget.userId, cleanedTopThree);

      // Zeige Erfolg
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.game.name} added to position #$_selectedPosition!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Trigger reload of game details
        context.read<GameBloc>().add(
          GetGameDetailsWithUserDataEvent(
            gameId: widget.game.id,
            userId: widget.userId,
          ),
        );
      }
    } catch (e) {
      print('Error updating top three: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update top 3: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}