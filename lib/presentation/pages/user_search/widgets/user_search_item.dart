// lib/presentation/pages/user_search/widgets/user_search_item.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../domain/entities/user/user.dart';

/// A visually appealing user item widget that displays user info and stats
class UserSearchItem extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final bool showFollowButton;
  final bool isFollowing;
  final bool isLoadingFollow;
  final VoidCallback? onFollowPressed;

  const UserSearchItem({
    super.key,
    required this.user,
    this.onTap,
    this.showFollowButton = true,
    this.isFollowing = false,
    this.isLoadingFollow = false,
    this.onFollowPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(colorScheme),
              const SizedBox(width: 16),
              // User info and stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildUserName(theme),
                        ),
                        if (showFollowButton) ...[
                          const SizedBox(width: 12),
                          _buildFollowButton(colorScheme),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (user.bio?.isNotEmpty ?? false) ...[
                      _buildBio(theme),
                      const SizedBox(height: 8),
                    ],
                    _buildStats(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    return Hero(
      tag: 'user_avatar_${user.id}',
      child: Container(
        width: 64,
        height: 64,
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
              ? CachedNetworkImage(
                  imageUrl: user.avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildAvatarPlaceholder(),
                  errorWidget: (context, url, error) =>
                      _buildAvatarPlaceholder(),
                )
              : _buildAvatarPlaceholder(),
        ),
      ),
    );
  }

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
          Text(
            '@${user.username}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  Widget _buildFollowButton(ColorScheme colorScheme) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: isLoadingFollow ? null : onFollowPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primary,
          foregroundColor: isFollowing
              ? colorScheme.onSurface
              : colorScheme.onPrimary,
          elevation: isFollowing ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isFollowing
                ? BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  )
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    isFollowing
                        ? colorScheme.onSurface
                        : colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
