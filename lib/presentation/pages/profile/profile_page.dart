import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/pages/auth/login_page.dart';
import 'package:gamer_grove/presentation/pages/collections/collections_page.dart';
import 'package:gamer_grove/presentation/pages/followers_following/followers_following_page.dart';
import 'package:gamer_grove/presentation/pages/profile/edit_profile_page.dart';
import 'package:gamer_grove/presentation/pages/profile/profile_statistics_page.dart';
import 'package:gamer_grove/presentation/pages/profile/widgets/delete_account_dialog.dart';
import 'package:gamer_grove/presentation/pages/settings/settings_bottom_sheet.dart';

/// Profile page showing the current user's profile
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate to login when signed out
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (context) => const LoginPage(),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final user = state.user;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: const Text('My Profile'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        // Scroll-controlled, otherwise Material caps the
                        // sheet at 9/16 of the screen and its footer — legal
                        // notice and version — is unreachable.
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const SettingsBottomSheet(),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        context.read<AuthBloc>().add(const SignOutEvent());
                      },
                    ),
                  ],
                ),
                _buildProfileHeader(context, user),
                _buildStats(context, user),
                _buildCollectionsButton(context, user),
                _buildStatisticsButton(context, user),
                _buildDeleteAccount(context, user),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // Avatar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: user.hasAvatar
                        ? CachedNetworkImageProvider(user.avatarUrl!)
                        : null,
                    child: !user.hasAvatar
                        ? Text(
                            user.username[0].toUpperCase(),
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Material(
                      color: theme.colorScheme.secondary,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => EditProfilePage(user: user),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit,
                            color: theme.colorScheme.onSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Username
            Text(
              user.effectiveDisplayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user.hasDisplayName)
              Text(
                '@${user.username}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            const SizedBox(height: 8),
            // Bio
            if (user.hasBio)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  user.bio!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, User user) {
    final theme = Theme.of(context);
    // The four tiles used to be amber, blue, purple and green — a rainbow that
    // sat wrong beside every theme but the one nobody picked. The scheme's own
    // three accents are built to sit together and follow the reader's choice.
    final scheme = theme.colorScheme;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              icon: Icons.star_rounded,
              value: user.totalGamesRated.toString(),
              label: 'Rated',
              color: scheme.primary,
            ),
            _buildStatItem(
              context,
              icon: Icons.people_rounded,
              value: user.followersCount.toString(),
              label: 'Followers',
              color: scheme.secondary,
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => FollowersFollowingPage(
                      userId: user.id,
                      type: FollowListType.followers,
                      username: user.effectiveDisplayName,
                    ),
                  ),
                );
              },
            ),
            _buildStatItem(
              context,
              icon: Icons.person_add_rounded,
              value: user.followingCount.toString(),
              label: 'Following',
              color: scheme.tertiary,
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => FollowersFollowingPage(
                      userId: user.id,
                      type: FollowListType.following,
                      username: user.effectiveDisplayName,
                    ),
                  ),
                );
              },
            ),
            if (user.averageRating != null)
              _buildStatItem(
                context,
                icon: Icons.analytics_rounded,
                value: user.averageRating!.toStringAsFixed(1),
                label: 'Avg Rating',
                color: scheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    final child = Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      );
    }

    return child;
  }

  Widget _buildCollectionsButton(BuildContext context, User user) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(CollectionsPage.route(user.id));
          },
          icon: const Icon(Icons.collections_bookmark_rounded),
          label: const Text('My Collections'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  /// Self-service account deletion (GDPR Art. 17 and a Play requirement for
  /// apps with accounts). Deliberately understated and last on the page.
  Widget _buildDeleteAccount(BuildContext context, User user) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Center(
          child: TextButton.icon(
            onPressed: () => unawaited(_deleteAccount(context, user)),
            icon: Icon(
              Icons.delete_forever_outlined,
              size: 18,
              color: theme.colorScheme.error,
            ),
            label: Text(
              'Delete account',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, User user) async {
    final bloc = context.read<AuthBloc>();
    if (!await confirmAccountDeletion(context, username: user.username)) return;
    bloc.add(const DeleteAccountEvent());
  }

  Widget _buildStatisticsButton(BuildContext context, User user) {
    final theme = Theme.of(context);

    // Only show if user has rated games
    if (user.totalGamesRated == 0) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (context) => ProfileStatisticsPage(userId: user.id),
              ),
            );
          },
          icon: const Icon(Icons.bar_chart_rounded),
          label: const Text('View Detailed Statistics'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
