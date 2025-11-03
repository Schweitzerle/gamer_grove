// lib/presentation/widgets/top_three_dialog.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_top_three.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:shimmer/shimmer.dart';

class TopThreeDialog extends StatefulWidget {
  const TopThreeDialog({
    super.key,
    required this.game,
    required this.onPositionSelected,
    required this.gameBloc,
    this.currentTopThree,
  });

  final Game game;
  final void Function(int) onPositionSelected;
  final GameBloc gameBloc;
  final List<Game>? currentTopThree;

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
    print('🔍 TopThreeDialog: Loading top three games...');
    print(
        '🔍 TopThreeDialog: currentTopThree provided: ${widget.currentTopThree != null}');

    if (widget.currentTopThree != null) {
      print(
          '🔍 TopThreeDialog: currentTopThree length: ${widget.currentTopThree!.length}');

      // Sort by position and fill the array
      final sortedGames = List<Game?>.filled(3, null);
      for (final game in widget.currentTopThree!) {
        print(
            '🔍 TopThreeDialog: Game "${game.name}" position: ${game.topThreePosition}');
        if (game.topThreePosition != null &&
            game.topThreePosition! >= 1 &&
            game.topThreePosition! <= 3) {
          sortedGames[game.topThreePosition! - 1] = game;
        }
      }

      print('🔍 TopThreeDialog: Sorted games:');
      for (int i = 0; i < sortedGames.length; i++) {
        print('   Position ${i + 1}: ${sortedGames[i]?.name ?? "Empty"}');
      }

      setState(() {
        _topThreeGames = sortedGames;
        _isLoading = false;
      });
    } else {
      print(
          '⚠️ TopThreeDialog: No currentTopThree provided - loading from backend');

      // Load top three directly from backend
      final userId = _getCurrentUserId();
      if (userId != null) {
        try {
          print('🔄 TopThreeDialog: Loading top three for user $userId');
          final getUserTopThree = sl<GetUserTopThree>();
          final result =
              await getUserTopThree(GetUserTopThreeParams(userId: userId));

          result.fold(
            (failure) {
              print(
                  '❌ TopThreeDialog: Failed to load top three: ${failure.message}');
              setState(() {
                _isLoading = false;
              });
            },
            (games) {
              print('✅ TopThreeDialog: Loaded ${games.length} top three games');
              final sortedGames = List<Game?>.filled(3, null);
              for (final game in games) {
                print(
                    '   Game: ${game.name} at position ${game.topThreePosition}');
                if (game.topThreePosition != null &&
                    game.topThreePosition! >= 1 &&
                    game.topThreePosition! <= 3) {
                  sortedGames[game.topThreePosition! - 1] = game;
                }
              }
              setState(() {
                _topThreeGames = sortedGames;
                _isLoading = false;
              });
            },
          );
        } catch (e) {
          print('❌ TopThreeDialog: Error loading top three: $e');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        print('⚠️ TopThreeDialog: No user ID available');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return null;
  }

  void _removeFromTopThree(Game game) {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    print('🗑️ TopThreeDialog: Removing game ${game.id} from top three');

    widget.gameBloc.add(
      RemoveFromTopThreeEvent(
        userId: userId,
        gameId: game.id,
      ),
    );

    setState(() {
      // Find and clear the position
      for (var i = 0; i < _topThreeGames.length; i++) {
        if (_topThreeGames[i]?.id == game.id) {
          _topThreeGames[i] = null;
          break;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${game.name} removed from Top 3'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - More compact
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add to Top 3',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.game.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Current Top Three Display
              if (_isLoading)
                _buildShimmerLoading()
              else ...[
                const Text(
                  'Current Top 3:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Display top 3 games with images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTopThreePosition(1),
                    _buildTopThreePosition(2),
                    _buildTopThreePosition(3),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
              ],

              // Position Selection Instructions
              Text(
                'Select position:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Position Selection Buttons - More compact
              _buildPositionButton(1),
              const SizedBox(height: 6),
              _buildPositionButton(2),
              const SizedBox(height: 6),
              _buildPositionButton(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShimmerCard(),
              _buildShimmerCard(),
              _buildShimmerCard(),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreePosition(int position) {
    final game = _topThreeGames[position - 1];
    final color = ColorScales.getRankingColor(position - 1);
    final emoji = position == 1
        ? '🥇'
        : position == 2
            ? '🥈'
            : '🥉';

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Position badge - more compact
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Game card or empty slot
            if (game == null)
              _buildEmptySlot()
            else
              _buildGameCard(game, position),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 24,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              'Empty',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(Game game, int position) {
    final color = ColorScales.getRankingColor(position - 1);

    return Stack(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: game.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: ImageUtils.getMediumImageUrl(game.coverUrl),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.videogame_asset,
                          size: 32,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.videogame_asset,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        // Remove Button - more compact
        Positioned(
          top: 3,
          right: 3,
          child: GestureDetector(
            onTap: () => _removeFromTopThree(game),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionButton(int position) {
    final currentGame = _topThreeGames[position - 1];
    final hasGame = currentGame != null;
    final emoji = position == 1
        ? '🥇'
        : position == 2
            ? '🥈'
            : '🥉';
    final title = position == 1
        ? '1st Place'
        : position == 2
            ? '2nd Place'
            : '3rd Place';

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        widget.onPositionSelected(position);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: hasGame ? Colors.orange[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasGame ? Colors.orange[200]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ColorScales.getRankingColor(position - 1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (hasGame)
                    Text(
                      'Replace: ${currentGame.name}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'Empty',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
