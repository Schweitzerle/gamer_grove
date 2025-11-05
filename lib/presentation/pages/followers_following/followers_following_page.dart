import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:gamer_grove/presentation/blocs/user_search/user_search_event.dart';
import 'package:gamer_grove/presentation/blocs/user_search/user_search_state.dart';
import 'package:gamer_grove/presentation/pages/user_detail/user_detail_page.dart';
import 'package:gamer_grove/presentation/pages/user_search/widgets/user_search_item.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/social_interactions/social_interactions_bloc.dart';
import '../../blocs/social_interactions/social_interactions_event.dart';
import '../../blocs/social_interactions/social_interactions_state.dart';

/// Types of follow lists
enum FollowListType {
  /// List of followers
  followers,

  /// List of following
  following
}

class FollowersFollowingPage extends StatefulWidget {
  const FollowersFollowingPage({
    required this.userId,
    required this.type,
    required this.username,
    super.key,
  });

  final String userId;
  final FollowListType type;
  final String username;

  @override
  State<FollowersFollowingPage> createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage> {
  late UserSearchBloc _searchBloc;
  late SocialInteractionsBloc _socialBloc;
  String? _currentUserId;
  final TextEditingController _searchController = TextEditingController();
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _searchBloc = sl<UserSearchBloc>();

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

    // Load followers or following based on type
    if (widget.type == FollowListType.followers) {
      _searchBloc.add(LoadFollowersRequested(widget.userId));
    } else {
      _searchBloc.add(LoadFollowingRequested(widget.userId));
    }

    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    unawaited(_searchBloc.close());
    unawaited(_socialBloc.close());
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers.where((user) {
          return user.username.toLowerCase().contains(query) ||
              (user.displayName?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.type == FollowListType.followers
        ? "${widget.username}'s Followers"
        : "${widget.username}'s Following";

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _searchBloc),
        BlocProvider.value(value: _socialBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          elevation: 0,
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surface,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _searchController.clear,
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Users List
            Expanded(
              child: BlocConsumer<UserSearchBloc, UserSearchState>(
                listener: (context, state) {
                  if (state.hasUsers && !state.isLoading) {
                    setState(() {
                      _allUsers = state.users;
                      _filteredUsers = List.from(state.users);
                    });

                    // Load follow status for all visible users
                    for (final user in _allUsers) {
                      if (_currentUserId != null && _currentUserId != user.id) {
                        _socialBloc.add(LoadFollowStatusRequested(user.id));
                      }
                    }
                  }
                },
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading users',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.errorMessage ?? 'Unknown error',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (widget.type == FollowListType.followers) {
                                _searchBloc
                                    .add(LoadFollowersRequested(widget.userId));
                              } else {
                                _searchBloc
                                    .add(LoadFollowingRequested(widget.userId));
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchController.text.isNotEmpty
                                ? Icons.search_off
                                : Icons.people_outline,
                            size: 64,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No users found'
                                : widget.type == FollowListType.followers
                                    ? 'No followers yet'
                                    : 'Not following anyone yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return BlocBuilder<SocialInteractionsBloc,
                          SocialInteractionsState>(
                        builder: (context, socialState) {
                          final isFollowing = socialState.isFollowing(user.id);
                          final isLoadingFollow = socialState.isLoading(user.id);

                          return UserSearchItem(
                            user: user,
                            showFollowButton: user.id != _currentUserId,
                            isFollowing: isFollowing,
                            isLoadingFollow: isLoadingFollow,
                            onFollowPressed: () {
                              context.read<SocialInteractionsBloc>().add(
                                    ToggleFollowRequested(
                                      user.id,
                                      isFollowing,
                                    ),
                                  );
                            },
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserDetailPage(
                                    user: user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
