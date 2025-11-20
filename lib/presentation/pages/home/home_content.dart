// presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
//import 'package:gamer_grove/presentation/widgets/sections/header_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/top_rated_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/upcoming_events_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/upcoming_games_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/popular_characters_section.dart';
import '../../../core/constants/app_constants.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../widgets/sections/latest_games_section.dart';
import '../../widgets/sections/popular_games_section.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
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
    _gameBloc.add(LoadHomePageDataEvent(userId: _currentUserId));
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
                actions: const [],
              ),

              /* // Header Section
              const SliverToBoxAdapter(
                child: HeaderSection(),
              ), */

              // Popular Games Section
              const SliverToBoxAdapter(
                child: PopularGamesSection(),
              ),

              // Upcoming Events Section (Carousel)
              SliverToBoxAdapter(
                child: UpcomingEventsSection(
                  currentUserId: _currentUserId,
                  gameBloc: _gameBloc,
                ),
              ),

              // Popular Characters Section
              const SliverToBoxAdapter(
                child: PopularCharactersSection(),
              ),

              // Latest Games Section
              const SliverToBoxAdapter(
                child: LatestGamesSection(),
              ),

              // Upcoming Games Section
              const SliverToBoxAdapter(
                child: UpcomingGamesSection(),
              ),

              // Top Rated Games Section
              const SliverToBoxAdapter(
                child: TopRatedGamesSection(),
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
