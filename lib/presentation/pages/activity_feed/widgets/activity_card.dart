import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/domain/entities/user_activity.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final UserActivity activity;
  final Widget content;
  final String title;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.content,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(context, activity.user),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: activity.user.username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' $title'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd.MM.yyyy').format(activity.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, dynamic user) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
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
      ),
      child: ClipOval(
        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: user.avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    _buildAvatarPlaceholder(context, user),
                errorWidget: (context, url, error) =>
                    _buildAvatarPlaceholder(context, user),
              )
            : _buildAvatarPlaceholder(context, user),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(BuildContext context, dynamic user) {
    return Center(
      child: Text(
        user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
