import 'package:flutter/material.dart';
import 'package:gamer_grove/domain/entities/user_activity.dart';

class ActivityFeedItem extends StatelessWidget {

  const ActivityFeedItem({required this.activity, super.key});
  final UserActivity activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(activity.user.avatarUrl ?? ''),
                ),
                const SizedBox(width: 16),
                Text('${activity.user.username} ${activity.activityType}'),
              ],
            ),
            if (activity.gameId != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Game ID: ${activity.gameId}'),
              ),
            const SizedBox(height: 8),
            Text(
              activity.createdAt.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
