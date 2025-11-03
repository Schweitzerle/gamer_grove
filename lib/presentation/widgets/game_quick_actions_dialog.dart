// Enhanced game_quick_actions_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import '../../domain/entities/game/game.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'rating_dialog.dart';
import 'top_three_dialog.dart';

class GameQuickActionsDialog extends StatefulWidget {
  final Game game;
  final GameBloc gameBloc;

  const GameQuickActionsDialog({
    super.key,
    required this.game,
    required this.gameBloc,
  });

  @override
  State<GameQuickActionsDialog> createState() => _GameQuickActionsDialogState();
}

class _GameQuickActionsDialogState extends State<GameQuickActionsDialog> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Game Info Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Game Cover
                if (widget.game.coverUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.game.coverUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 12),

                // Game Title & Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Current Status Tags
                      Wrap(
                        spacing: 6,
                        children: [
                          if (widget.game.isInTopThree)
                            _buildStatusChip(
                              label: '#${widget.game.topThreePosition ?? "3"}',
                              icon: Icons.emoji_events,
                              color: Colors.amber,
                            ),
                          if (widget.game.userRating != null)
                            _buildStatusChip(
                              label: widget.game.userRating!.toStringAsFixed(1),
                              icon: Icons.star,
                              color: ColorScales.getRatingColor(
                                  widget.game.userRating!),
                            ),
                          if (widget.game.isWishlisted)
                            _buildStatusChip(
                              label: 'Wishlist',
                              icon: Icons.favorite,
                              color: Colors.red,
                            ),
                          if (widget.game.isRecommended)
                            _buildStatusChip(
                              label: 'Recommended',
                              icon: Icons.thumb_up,
                              color: Colors.green,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Quick Actions Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: widget.game.userRating != null
                        ? Icons.star
                        : Icons.star_outline,
                    label: widget.game.userRating != null ? 'Rated' : 'Rate',
                    color: Colors.amber,
                    isActive: widget.game.userRating != null,
                    onTap: _rateGame,
                  ),
                  _buildActionButton(
                    icon: widget.game.isWishlisted
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    label: 'Wishlist',
                    color: Colors.red,
                    isActive: widget.game.isWishlisted,
                    onTap: _toggleWishlist,
                  ),
                  _buildActionButton(
                    icon: widget.game.isRecommended
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    label: 'Recommend',
                    color: Colors.green,
                    isActive: widget.game.isRecommended,
                    onTap: _toggleRecommend,
                  ),
                  _buildActionButton(
                      icon: Icons.emoji_events,
                      label: 'Top 3',
                      color: Colors.orange,
                      isActive: widget.game.isInTopThree,
                      onTap: () {
                        _showTopThreeDialog(widget.game);
                      }),
                ]),
          ),

          // Bottom padding for gesture area
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? color : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isActive ? color : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _rateGame() {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (context) => RatingDialog(
        gameName: widget.game.name,
        currentRating: widget.game.userRating,
        onRatingSubmitted: (rating) {
          widget.gameBloc.add(RateGameEvent(
            gameId: widget.game.id,
            userId: _currentUserId!,
            rating: rating,
          ));
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  void _toggleWishlist() {
    widget.gameBloc.add(ToggleWishlistEvent(
      gameId: widget.game.id,
      userId: _currentUserId!,
    ));
    Navigator.pop(context);
    HapticFeedback.lightImpact();
  }

  void _toggleRecommend() {
    widget.gameBloc.add(ToggleRecommendEvent(
      gameId: widget.game.id,
      userId: _currentUserId!,
    ));
    Navigator.pop(context);
    HapticFeedback.lightImpact();
  }

  void _showTopThreeDialog(Game game) {
    if (_currentUserId == null) {
      _showLoginRequiredSnackBar();
      return;
    }

    print('🎯 QuickActions: Opening top three dialog for "${game.name}"');

    // Get current top three games from the bloc state
    List<Game>? currentTopThree;
    final currentState = widget.gameBloc.state;

    print('🎯 QuickActions: GameBloc state type: ${currentState.runtimeType}');

    if (currentState is GrovePageLoaded) {
      currentTopThree = currentState.userTopThree;
      print('✅ QuickActions: Found GrovePageLoaded with ${currentTopThree.length} top three games');
    } else {
      print('⚠️ QuickActions: State is not GrovePageLoaded, currentTopThree will be null');
    }

    showDialog<void>(
      context: context,
      builder: (context) => TopThreeDialog(
        game: game,
        gameBloc: widget.gameBloc,
        currentTopThree: currentTopThree,
        onPositionSelected: (position) {
          _addToTopThree(game.id, position);
        },
      ),
    );
  }

  void _addToTopThree(int gameId, int position) {
    if (_currentUserId == null) return;

    print('🎯 QuickActions: Adding game $gameId to top three at position $position');
    print('🎯 QuickActions: User ID: $_currentUserId');

    widget.gameBloc.add(AddToTopThreeEvent(
      gameId: gameId,
      userId: _currentUserId!,
      position: position,
    ));

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to Top 3 at position $position'),
        backgroundColor: Colors.amber,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLoginRequiredSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login to use this feature'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
