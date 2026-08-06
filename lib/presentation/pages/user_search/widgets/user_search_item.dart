// lib/presentation/pages/user_search/widgets/user_search_item.dart

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/core/widgets/cached_image_widget.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/presentation/pages/leaderboard/widgets/leaderboard_rank.dart';

/// One person, in a list of people — search, leaderboard, followers.
///
/// The widths used not to add up. On a 320-dp screen the list's own padding
/// (32), this card's margin (32), a rank column (50), the card's padding (32)
/// and a 64-px avatar left **nothing** for the name — it rendered at width
/// zero — and pushed the follow button 30 px past the right edge. Reported from
/// the device as "the follow button sometimes overlaps"; the "sometimes" was
/// only how long the name happened to be.
///
/// Three of those five are gone: the margin belongs to the list that owns the
/// spacing, the rank is worn on the avatar, and the button sits at the trailing
/// edge of the row instead of competing with the name inside it.
class UserSearchItem extends StatelessWidget {
  const UserSearchItem({
    required this.user,
    super.key,
    this.onTap,
    this.showFollowButton = true,
    this.isFollowing = false,
    this.isLoadingFollow = false,
    this.onFollowPressed,
    this.rank,
  });
  final User user;
  final VoidCallback? onTap;
  final bool showFollowButton;
  final bool isFollowing;
  final bool isLoadingFollow;
  final VoidCallback? onFollowPressed;

  /// Position on the leaderboard, worn as a badge on the avatar. Null
  /// everywhere the list is not a ranking.
  final int? rank;

  /// Smaller than the 64 it was. At 320 dp those extra pixels were the
  /// difference between a readable name and none.
  static const _avatar = 52.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tokens = context.ggTokens;

    // No margin. Every list that shows this already pads itself and puts a
    // separator between rows; carrying its own on top doubled both.
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceMd),
          // The row decides from its own width, not from the screen's: the same
          // item sits in three lists, and one of them used to stand a column
          // beside it.
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Scaled with the reader's type size: at 200 % the same label
              // needs twice the room, and a threshold that ignored that would
              // put the row back over its edge for exactly the people who can
              // least afford it.
              final labelled = constraints.maxWidth >=
                  _roomForLabel * MediaQuery.textScalerOf(context).scale(1);
              return Row(
                children: [
                  _buildAvatar(colorScheme),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildUserName(theme),
                        if (user.bio?.isNotEmpty ?? false) ...[
                          SizedBox(height: tokens.spaceXs),
                          _buildBio(theme),
                        ],
                        SizedBox(height: tokens.spaceSm),
                        _buildStats(theme),
                      ],
                    ),
                  ),
                  if (showFollowButton) ...[
                    SizedBox(width: tokens.spaceSm),
                    _buildFollowButton(context, colorScheme,
                        labelled: labelled),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Below this the button drops its label and keeps only the mark.
  ///
  /// Measured, not guessed: the labelled button is 104 px wide, the avatar 52,
  /// the gaps 24 and the card's padding 32. Leaving the name a hundred px to
  /// read in puts the turn at a little over three hundred — which a 320-dp
  /// screen is under and a 360-dp one is over.
  static const _roomForLabel = 312.0;

  /// What the longer of the two labels needs. Measured at 104 px; both states
  /// are held to it so rows do not change height as you follow people.
  static const _labelledWidth = 104.0;

  Widget _buildAvatar(ColorScheme colorScheme) {
    final portrait = Hero(
      tag: 'user_avatar_${user.id}',
      child: Container(
        width: _avatar,
        height: _avatar,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: user.hasAvatar
              ? CachedImageWidget(
                  imageUrl: user.avatarUrl,
                  placeholder: _buildAvatarPlaceholder(),
                  errorWidget: _buildAvatarPlaceholder(),
                )
              : _buildAvatarPlaceholder(),
        ),
      ),
    );

    final place = rank;
    if (place == null) return portrait;

    // The badge hangs off the bottom edge, so it costs the row no width at all
    // — which was the whole reason the rank column had to go.
    return SizedBox(
      width: _avatar,
      height: _avatar,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          portrait,
          Positioned(
            left: -_badgeOverhang,
            bottom: -_badgeOverhang,
            child: LeaderboardRank(rank: place),
          ),
        ],
      ),
    );
  }

  static const _badgeOverhang = 4.0;

  Widget _buildAvatarPlaceholder() {
    return Center(
      child: Text(
        user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUserName(ThemeData theme) {
    return Row(
      children: [
        Flexible(
          child: Text(
            user.effectiveDisplayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (user.hasDisplayName) ...[
          const SizedBox(width: 4),
          // Flexible as well: a handle is user-supplied and can be as long as
          // the name it sits beside, and a fixed one pushed the row open.
          Flexible(
            child: Text(
              '@${user.username}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBio(ThemeData theme) {
    return Text(
      user.bio!,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatChip(
          icon: Icons.star_rounded,
          label: '${user.totalGamesRated}',
          tooltip: 'Rated Games',
          color: Colors.amber,
        ),
        _buildStatChip(
          icon: Icons.people_rounded,
          label: '${user.followersCount}',
          tooltip: 'Followers',
          color: Colors.blue,
        ),
        if (user.averageRating != null)
          _buildStatChip(
            icon: Icons.analytics_rounded,
            label: user.averageRating!.toStringAsFixed(1),
            tooltip: 'Average Rating',
            color: Colors.green,
          ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String tooltip,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(
    BuildContext context,
    ColorScheme colorScheme, {
    required bool labelled,
  }) {
    final action = isFollowing ? 'Unfollow' : 'Follow';
    // 36 was below the 48-dp minimum for a tap target, and the semantics test
    // said so the moment one existed.
    final button = SizedBox(
      height: context.ggTokens.minTapTarget,
      child: ElevatedButton(
        onPressed: isLoadingFollow ? null : onFollowPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primary,
          foregroundColor:
              isFollowing ? colorScheme.onSurface : colorScheme.onPrimary,
          elevation: isFollowing ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isFollowing
                ? BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  )
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          visualDensity: VisualDensity.compact,
          // A floor, not a cap: "Follow" and "Following" then take the same
          // width, so a list of people has one rhythm instead of a ragged
          // right edge that moves with who you happen to follow.
          minimumSize: Size(
            labelled ? _labelledWidth : 0,
            context.ggTokens.minTapTarget,
          ),
          disabledBackgroundColor: isFollowing
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primary.withValues(alpha: 0.5),
        ),
        child: isLoadingFollow
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFollowing ? colorScheme.onSurface : colorScheme.onPrimary,
                  ),
                ),
              )
            : labelled
                ? Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                // The mark alone, never a shortened word. `Tooltip` and the
                // semantic label carry what the text did, so nothing is lost
                // to a screen reader or a long press.
                : Icon(
                    isFollowing ? Icons.check_rounded : Icons.person_add_alt_1,
                    size: 20,
                  ),
      ),
    );

    return Semantics(
      button: true,
      label: '$action ${user.effectiveDisplayName}',
      child: ExcludeSemantics(
        child: labelled
            ? button
            : Tooltip(
                message: '$action ${user.effectiveDisplayName}', child: button),
      ),
    );
  }
}
