import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/pages/activity_feed/activity_feed_page.dart';
import 'package:gamer_grove/presentation/pages/followers_following/followers_following_page.dart';
import 'package:gamer_grove/presentation/pages/leaderboard/leaderboard_page.dart';
import 'package:gamer_grove/presentation/pages/user_search/user_search_page.dart';




class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Coming Soon'),
          const SizedBox(height: 16),
          _buildComingSoonFeatures(context),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Quick Actions'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.search_rounded,
                title: 'Find Users',
                subtitle: 'Search for gamers',
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => const UserSearchPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.group_rounded,
                title: 'Following',
                subtitle: 'See who you follow',
                color: Colors.purple,
                onTap: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (context) => FollowersFollowingPage(
                          userId: authState.user.id,
                          type: FollowListType.following,
                          username: authState.user.username,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You need to be logged in to see your following list.'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildComingSoonFeatures(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.feed_rounded,
        title: 'Activity Feed',
        description: 'See what your friends are playing',
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) => const ActivityFeedPage(),
            ),
          );
        },
      ),
      _FeatureItem(
        icon: Icons.leaderboard_rounded,
        title: 'Leaderboards',
        description: 'Compete with other gamers',
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) => const LeaderboardPage(),
            ),
          );
        },
      ),
    ];

    return Column(
      children: features.map((feature) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: feature.onTap,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                feature.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              feature.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(feature.description),
            trailing: feature.onTap == null
                ? const Chip(
                    label: Text(
                      'Soon',
                      style: TextStyle(fontSize: 11),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  )
                : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });
}
