// lib/presentation/pages/user_detail/user_detail_page.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/blocs/social_interactions/social_interactions_bloc.dart';
import 'package:gamer_grove/presentation/blocs/social_interactions/social_interactions_event.dart';
import 'package:gamer_grove/presentation/blocs/social_interactions/social_interactions_state.dart';
import 'package:gamer_grove/presentation/pages/followers_following/followers_following_page.dart';
import 'package:gamer_grove/presentation/widgets/sections/rated_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/recommendations_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/top_three_section.dart';

/// User detail page showing profile and game collections
class UserDetailPage extends StatefulWidget {
  const UserDetailPage({
    required this.user,
    super.key,
  });

  final User user;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late GameBloc _gameBloc;
  late SocialInteractionsBloc _socialBloc;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _gameBloc = sl<GameBloc>();

    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    }

    _socialBloc = SocialInteractionsBloc(
      followUser: sl(),
      unfollowUser: sl(),
      userRepository: sl(),
      currentUserId: _currentUserId,
    );

    // Load initial follow status
    if (_currentUserId != null && _currentUserId != widget.user.id) {
      _socialBloc.add(LoadFollowStatusRequested(widget.user.id));
    }

    // Load user's game data
    _gameBloc.add(LoadGrovePageDataEvent(userId: widget.user.id));
  }

  @override
  void dispose() {
    unawaited(_gameBloc.close());
    unawaited(_socialBloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _gameBloc),
        BlocProvider.value(value: _socialBloc),
      ],
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            _gameBloc.add(LoadGrovePageDataEvent(userId: widget.user.id));
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Text(widget.user.effectiveDisplayName),
              ),
              _buildProfileHeader(),
              _buildStats(),
              if (widget.user.showTopThree)
                SliverToBoxAdapter(
                  child: TopThreeSection(
                    username: widget.user.effectiveDisplayName,
                  ),
                ),
              if (widget.user.showRatedGames)
                SliverToBoxAdapter(
                  child: RatedSection(
                    username: widget.user.effectiveDisplayName,
                  ),
                ),
              if (widget.user.showRecommendedGames)
                SliverToBoxAdapter(
                  child: RecommendationsSection(
                    username: widget.user.effectiveDisplayName,
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: widget.user.hasAvatar
                    ? CachedNetworkImageProvider(widget.user.avatarUrl!)
                    : null,
                child: !widget.user.hasAvatar
                    ? Text(
                        widget.user.username[0].toUpperCase(),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            // Username
            Text(
              widget.user.effectiveDisplayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.user.hasDisplayName)
              Text(
                '@${widget.user.username}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            const SizedBox(height: 8),
            // Bio
            if (widget.user.hasBio)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.user.bio!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 16),
            // Follow Button (if not own profile)
            if (_currentUserId != null && _currentUserId != widget.user.id)
              BlocBuilder<SocialInteractionsBloc, SocialInteractionsState>(
                builder: (context, state) {
                  final isFollowing = state.isFollowing(widget.user.id);
                  final isLoading = state.isLoading(widget.user.id);

                  return ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<SocialInteractionsBloc>().add(
                                  ToggleFollowRequested(
                                    widget.user.id,
                                    isFollowing,
                                  ),
                                );
                          },
                    icon: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFollowing
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Icon(
                            isFollowing ? Icons.check : Icons.person_add,
                            size: 20,
                          ),
                    label: Text(isFollowing ? 'Following' : 'Follow'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.primary,
                      foregroundColor: isFollowing
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: isFollowing
                            ? BorderSide(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.5),
                              )
                            : BorderSide.none,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final theme = Theme.of(context);

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
              icon: Icons.star_rounded,
              value: widget.user.totalGamesRated.toString(),
              label: 'Rated',
              color: Colors.amber,
            ),
            _buildStatItem(
              icon: Icons.people_rounded,
              value: widget.user.followersCount.toString(),
              label: 'Followers',
              color: Colors.blue,
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => FollowersFollowingPage(
                      userId: widget.user.id,
                      type: FollowListType.followers,
                      username: widget.user.effectiveDisplayName,
                    ),
                  ),
                );
              },
            ),
            _buildStatItem(
              icon: Icons.person_add_rounded,
              value: widget.user.followingCount.toString(),
              label: 'Following',
              color: Colors.purple,
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (context) => FollowersFollowingPage(
                      userId: widget.user.id,
                      type: FollowListType.following,
                      username: widget.user.effectiveDisplayName,
                    ),
                  ),
                );
              },
            ),
            if (widget.user.averageRating != null)
              _buildStatItem(
                icon: Icons.analytics_rounded,
                value: widget.user.averageRating!.toStringAsFixed(1),
                label: 'Avg Rating',
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
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
}
