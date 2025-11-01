// lib/presentation/widgets/top_three_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game/game.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class TopThreeDialog extends StatefulWidget {
  final Game game;
  final void Function(int) onPositionSelected;
  final List<Game>? currentTopThree; // Current top 3 games

  const TopThreeDialog({
    super.key,
    required this.game,
    required this.onPositionSelected,
    this.currentTopThree,
  });

  @override
  State<TopThreeDialog> createState() => _TopThreeDialogState();
}

class _TopThreeDialogState extends State<TopThreeDialog> {
  bool _isLoading = true;
  List<Game?> _topThreeGames = [null, null, null];

  @override
  void initState() {
    super.initState();
    _loadTopThreeGames();
  }

  Future<void> _loadTopThreeGames() async {
    if (widget.currentTopThree != null) {
      setState(() {
        _topThreeGames = List.from(widget.currentTopThree!);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return null;
  }

  void _removeFromTopThree(int gameId) {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    final gameBloc = context.read<GameBloc>();
    gameBloc.add(RemoveFromTopThreeEvent(
      userId: userId,
      gameId: gameId,
    ));

    setState(() {
      _topThreeGames.removeWhere((game) => game?.id == gameId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from Top 3'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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

              // Current Top Three
              if (!_isLoading) ...[
                const Text(
                  'Current Top 3:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTopThreeCard(1)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTopThreeCard(2)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTopThreeCard(3)),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Position Selection
              const Text(
                'Select position:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Position Buttons
              Column(
                children: [
                  _buildPositionTile(1, '🥇', 'First Place'),
                  _buildPositionTile(2, '🥈', 'Second Place'),
                  _buildPositionTile(3, '🥉', 'Third Place'),
                ],
              ),

              const SizedBox(height: 24),

              // Cancel Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopThreeCard(int position) {
    final game = _topThreeGames.firstWhere((game) => game?.topThreePosition == position, orElse: () => null);
    final color = _getPositionColor(position);

    if (game == null) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              position == 1 ? '🥇' : position == 2 ? '🥈' : '🥉',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              'Empty',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color,
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: game.coverUrl != null
                ? Image.network(
                    game.coverUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.videogame_asset,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.videogame_asset,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        // Position Badge
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              position == 1 ? '🥇' : position == 2 ? '🥈' : '🥉',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        // Delete Button
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _removeFromTopThree(game.id),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionTile(int position, String emoji, String title) {
    final currentGame = _topThreeGames.firstWhere((game) => game?.topThreePosition == position, orElse: () => null);
    final hasGame = currentGame != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getPositionColor(position),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(title),
        subtitle: Text(hasGame
          ? 'Replace: ${currentGame.name}'
          : 'Position $position (Empty)'),
        onTap: () {
          Navigator.of(context).pop();
          widget.onPositionSelected(position);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: hasGame ? Colors.orange[50] : Colors.grey[50],
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
}
