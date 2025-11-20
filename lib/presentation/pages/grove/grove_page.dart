import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/sections/rated_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/recommendations_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/top_three_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/wishlist_section.dart';

class GrovePage extends StatefulWidget {
  const GrovePage({super.key});

  @override
  State<GrovePage> createState() => _GrovePageState();
}

class _GrovePageState extends State<GrovePage> {
  late GameBloc _gameBloc;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _gameBloc = sl<GameBloc>();
    _loadInitialData();
  }

  @override
  void dispose() {
    _gameBloc.close();
    super.dispose();
  }

  void _loadInitialData() {
    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    } else {
    }

    // Load all data at once
    if (_currentUserId != null) {
      _gameBloc.add(LoadGrovePageDataEvent(userId: _currentUserId));
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameBloc,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            _loadInitialData();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return SliverAppBar(
                    floating: true,
                    title: Row(
                      children: [
                        Icon(
                          Icons.gamepad_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text('Gamer Grove'),
                      ],
                    ),
                    actions: [
                      if (authState is AuthAuthenticated)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildProfileAvatar(context, authState.user),
                        ),
                    ],
                  );
                },
              ),

              if (_currentUserId != null)
                SliverToBoxAdapter(
                  child: TopThreeSection(
                    currentUserId: _currentUserId,
                    gameBloc: _gameBloc,
                  ),
                ),

              // Rated Game Section
              if (_currentUserId != null)
                SliverToBoxAdapter(
                  child: RatedSection(
                    currentUserId: _currentUserId,
                    gameBloc: _gameBloc,
                  ),
                ),

              // User Wishlist Section (if logged in)
              if (_currentUserId != null)
                SliverToBoxAdapter(
                  child: WishlistSection(
                    currentUserId: _currentUserId,
                    gameBloc: _gameBloc,
                  ),
                ),

              // User Recommendations Section (if logged in)
              if (_currentUserId != null)
                SliverToBoxAdapter(
                  child: RecommendationsSection(
                    currentUserId: _currentUserId,
                    gameBloc: _gameBloc,
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.paddingXLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, User user) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: user.hasAvatar
            ? CachedNetworkImageProvider(user.avatarUrl!)
            : null,
        child: !user.hasAvatar
            ? Text(
                user.username[0].toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
