// lib/presentation/pages/user_search/user_search_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/social_interactions/social_interactions_bloc.dart';
import 'package:gamer_grove/presentation/blocs/social_interactions/social_interactions_event.dart';
import 'package:gamer_grove/presentation/blocs/social_interactions/social_interactions_state.dart';
import 'package:gamer_grove/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:gamer_grove/presentation/blocs/user_search/user_search_event.dart';
import 'package:gamer_grove/presentation/blocs/user_search/user_search_state.dart';
import 'package:gamer_grove/presentation/pages/user_detail/user_detail_page.dart';
import 'package:gamer_grove/presentation/pages/user_search/widgets/user_search_item.dart';

/// User search page with paginated results
class UserSearchPage extends StatelessWidget {
  const UserSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user ID from auth bloc
    final currentUserId = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user.id : null;
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<UserSearchBloc>(),
        ),
        BlocProvider(
          create: (context) => SocialInteractionsBloc(
            followUser: sl(),
            unfollowUser: sl(),
            userRepository: sl(),
            currentUserId: currentUserId,
          ),
        ),
      ],
      child: const _UserSearchContent(),
    );
  }
}

class _UserSearchContent extends StatefulWidget {
  const _UserSearchContent();

  @override
  State<_UserSearchContent> createState() => _UserSearchContentState();
}

class _UserSearchContentState extends State<_UserSearchContent> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final Set<String> _loadedFollowStatuses = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UserSearchBloc>().add(const LoadMoreUsersRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    _loadedFollowStatuses.clear();
    context.read<UserSearchBloc>().add(SearchUsersRequested(query));
  }

  void _clearSearch() {
    _searchController.clear();
    _loadedFollowStatuses.clear();
    context.read<UserSearchBloc>().add(const ClearSearchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Users'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search users by username...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocConsumer<UserSearchBloc, UserSearchState>(
      listener: (context, state) {
        // Load follow status for each user when search results are loaded
        if (state.users.isNotEmpty && !state.isLoading) {
          final socialBloc = context.read<SocialInteractionsBloc>();
          for (final user in state.users) {
            // Only load follow status once per user
            if (!_loadedFollowStatuses.contains(user.id)) {
              _loadedFollowStatuses.add(user.id);
              socialBloc.add(LoadFollowStatusRequested(user.id));
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

        if (state.hasError && state.users.isEmpty) {
          return _buildErrorView(state.errorMessage!);
        }

        if (!state.isSearching) {
          return _buildEmptySearchView();
        }

        if (state.isEmpty) {
          return _buildNoResultsView();
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<UserSearchBloc>().add(const RefreshSearchRequested());
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.hasReachedMax
                ? state.users.length
                : state.users.length + 1,
            itemBuilder: (context, index) {
              if (index >= state.users.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final user = state.users[index];
              return BlocBuilder<SocialInteractionsBloc,
                  SocialInteractionsState>(
                builder: (context, socialState) {
                  final isFollowing = socialState.isFollowing(user.id);
                  final isLoading = socialState.isLoading(user.id);

                  return UserSearchItem(
                    user: user,
                    isFollowing: isFollowing,
                    isLoadingFollow: isLoading,
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (context) => UserDetailPage(user: user),
                        ),
                      );
                    },
                    onFollowPressed: () {
                      context
                          .read<SocialInteractionsBloc>()
                          .add(ToggleFollowRequested(user.id, isFollowing));
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptySearchView() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for Users',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a username to start searching',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_rounded,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Users Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Try searching with a different username',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: theme.colorScheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<UserSearchBloc>().add(const RetrySearchRequested());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
