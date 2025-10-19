import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/widgets/sections/rated_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/top_three_section.dart';
import '../../../core/constants/app_constants.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../widgets/sections/recommendations_section.dart';
import '../../widgets/sections/wishlist_section.dart';

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
    }

    // Load all data at once
    _gameBloc.add(LoadGrovePageDataEvent(userId: _currentUserId));
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
              SliverAppBar(
                floating: true,
                pinned: false,
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
              ),

              if (_currentUserId != null)
                const SliverToBoxAdapter(
                  child: TopThreeSection(),
                ),

              // Rated Game Section
              if (_currentUserId != null)
                const SliverToBoxAdapter(
                  child: RatedSection(),
                ),

              // User Wishlist Section (if logged in)
              if (_currentUserId != null)
                const SliverToBoxAdapter(
                  child: WishlistSection(),
                ),

              // User Recommendations Section (if logged in)
              if (_currentUserId != null)
                const SliverToBoxAdapter(
                  child: RecommendationsSection(),
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
}
