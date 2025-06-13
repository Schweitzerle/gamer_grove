// lib/presentation/widgets/game_quick_actions_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game.dart';
import '../../injection_container.dart';
import '../../data/datasources/remote/supabase_remote_datasource.dart';
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
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }
  }

  void _rateGame() {
    Navigator.pop(context); // Close quick actions

    showDialog(
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
          _showFeedback('Game rated ${rating.toStringAsFixed(1)}/10', Colors.green);
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
    _showFeedback(
      widget.game.isWishlisted ? 'Removed from wishlist' : 'Added to wishlist',
      widget.game.isWishlisted ? Colors.orange : Colors.green,
    );
  }

  void _toggleRecommend() {
    widget.gameBloc.add(ToggleRecommendEvent(
      gameId: widget.game.id,
      userId: _currentUserId!,
    ));

    Navigator.pop(context);
    _showFeedback(
      widget.game.isRecommended ? 'Removed recommendation' : 'Game recommended!',
      widget.game.isRecommended ? Colors.orange : Colors.green,
    );
  }

  void _addToTopThree() {
    Navigator.pop(context); // Close quick actions

    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: widget.gameBloc,
        child: TopThreeDialog(
          game: widget.game,
          userId: _currentUserId!,
          currentTopThree: [], // TODO: Get from user profile
        ),
      ),
    );
  }

  void _showFeedback(String message, Color color) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _currentUserId != null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Game Info Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Game Cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.game.coverUrl ?? '',
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 80,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.gamepad),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Game Title and Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (widget.game.genres.isNotEmpty)
                        Text(
                          widget.game.genres.take(2).map((g) => g.name).join(', '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (widget.game.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.game.rating!.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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

          // Quick Actions
          if (!isLoggedIn)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Please log in to use quick actions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else ...[
            // Rate Action
            _QuickActionTile(
              icon: Icons.star,
              title: 'Rate Game',
              subtitle: widget.game.userRating != null
                  ? 'Your rating: ${widget.game.userRating!.toStringAsFixed(1)}/10'
                  : 'Not rated yet',
              onTap: _rateGame,
              color: Colors.amber,
              isActive: widget.game.userRating != null,
            ),

            // Wishlist Action
            _QuickActionTile(
              icon: widget.game.isWishlisted ? Icons.favorite : Icons.favorite_outline,
              title: widget.game.isWishlisted ? 'Remove from Wishlist' : 'Add to Wishlist',
              subtitle: widget.game.isWishlisted
                  ? 'This game is in your wishlist'
                  : 'Save for later',
              onTap: _toggleWishlist,
              color: Colors.red,
              isActive: widget.game.isWishlisted,
            ),

            // Recommend Action
            _QuickActionTile(
              icon: widget.game.isRecommended ? Icons.thumb_up : Icons.thumb_up_outlined,
              title: widget.game.isRecommended ? 'Remove Recommendation' : 'Recommend',
              subtitle: widget.game.isRecommended
                  ? 'You recommend this game'
                  : 'Recommend to others',
              onTap: _toggleRecommend,
              color: Colors.green,
              isActive: widget.game.isRecommended,
            ),

            // Top 3 Action
            _QuickActionTile(
              icon: Icons.emoji_events,
              title: 'Add to Top 3',
              subtitle: 'Add to your favorite games',
              onTap: _addToTopThree,
              color: Colors.orange,
              isActive: false, // TODO: Check if in top 3
            ),
          ],

          // Bottom padding for gesture area
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  final bool isActive;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? color : Theme.of(context).colorScheme.outline,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? color : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? color : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}