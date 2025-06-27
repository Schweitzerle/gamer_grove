// ==================================================
// ACCORDION SECTIONS - EXPANDABLE USER STATES & COMMUNITY INFO
// ==================================================

// lib/presentation/pages/game_detail/widgets/user_states_section.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/game/game.dart';

class UserStatesSection extends StatefulWidget {
  final Game game;
  final VoidCallback? onRatePressed;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onToggleRecommend;
  final VoidCallback? onAddToTopThree;

  const UserStatesSection({
    super.key,
    required this.game,
    this.onRatePressed,
    this.onToggleWishlist,
    this.onToggleRecommend,
    this.onAddToTopThree,
  });

  @override
  State<UserStatesSection> createState() => _UserStatesSectionState();
}

class _UserStatesSectionState extends State<UserStatesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        child: Column(
          children: [
            // ✅ Accordion Header - immer sichtbar
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Row(
                    children: [
                      // Icon & Title
                      Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Activity',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      // Status Preview (when collapsed)
                      if (!_isExpanded) _buildStatusPreview(),

                      const SizedBox(width: 8),

                      // Expand/Collapse Icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ Expandable Content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingMedium,
                  0,
                  AppConstants.paddingMedium,
                  AppConstants.paddingMedium,
                ),
                child: Column(
                  children: [
                    // First Row
                    Row(
                      children: [
                        // User Rating Card
                        Expanded(
                          child: _buildMediumInfoCard(
                            context,
                            icon: widget.game.userRating != null ? Icons.star : Icons.star_outline,
                            label: 'Rate',
                            value: widget.game.userRating != null
                                ? '${(widget.game.userRating! * 10).toStringAsFixed(1)}/10'
                                : 'Rate it',
                            color: widget.game.userRating != null
                                ? ColorScales.getRatingColor(widget.game.userRating! * 10)
                                : Colors.grey,
                            isActive: widget.game.userRating != null,
                            onTap: widget.onRatePressed,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Wishlist Card
                        Expanded(
                          child: _buildMediumInfoCard(
                            context,
                            icon: widget.game.isWishlisted == true ? Icons.favorite : Icons.favorite_outline,
                            label: 'Wishlist',
                            value: widget.game.isWishlisted == true ? 'Added' : 'Add',
                            color: widget.game.isWishlisted == true ? Colors.red : Colors.grey,
                            isActive: widget.game.isWishlisted == true,
                            onTap: widget.onToggleWishlist,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Second Row
                    Row(
                      children: [
                        // Recommend Card
                        Expanded(
                          child: _buildMediumInfoCard(
                            context,
                            icon: widget.game.isRecommended == true ? Icons.thumb_up : Icons.thumb_up_outlined,
                            label: 'Recommend',
                            value: widget.game.isRecommended == true ? 'Recommended' : 'Recommend',
                            color: widget.game.isRecommended == true ? Colors.green : Colors.grey,
                            isActive: widget.game.isRecommended == true,
                            onTap: widget.onToggleRecommend,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Top Three Card
                        Expanded(
                          child: _buildMediumInfoCard(
                            context,
                            icon: widget.game.isInTopThree == true ? Icons.emoji_events : Icons.emoji_events_outlined,
                            label: 'Top 3',
                            value: widget.game.isInTopThree == true
                                ? '#${widget.game.topThreePosition ?? 1}'
                                : 'Add to Top 3',
                            color: widget.game.isInTopThree == true
                                ? ColorScales.getTopThreeColor(widget.game.topThreePosition ?? 1)
                                : Colors.grey,
                            isActive: widget.game.isInTopThree == true,
                            onTap: widget.onAddToTopThree,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Status Preview für collapsed state
  Widget _buildStatusPreview() {
    List<String> activeStates = [];

    if (widget.game.userRating != null) {
      activeStates.add('⭐${(widget.game.userRating! * 10).toStringAsFixed(1)}');
    }

    if (widget.game.isWishlisted == true) {
      activeStates.add('❤️');
    }

    if (widget.game.isRecommended == true) {
      activeStates.add('👍');
    }

    if (widget.game.isInTopThree == true) {
      activeStates.add('🏆#${widget.game.topThreePosition ?? 1}');
    }

    if (activeStates.isEmpty) {
      return Text(
        'No activity',
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.withOpacity(0.7),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      activeStates.join(' • '),
      style: TextStyle(
        fontSize: 10,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }

  // ✅ Medium-sized Info Card (kleiner als original, größer als compact)
  Widget _buildMediumInfoCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
        required bool isActive,
        VoidCallback? onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.6)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? color.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive
                      ? color.onColor.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: isActive ? color : Colors.grey,
                  size: 20,
                ),
              ),

              const SizedBox(height: 6),

              // Label
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 3),

              // Value
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive ? color.lighten(20) : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

