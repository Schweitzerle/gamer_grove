// lib/presentation/pages/characters/widgets/character_games_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/navigations.dart';
import '../../../../domain/entities/character/character.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../widgets/game_card.dart';

class CharacterGamesSection extends StatefulWidget {
  final Character character;
  final List<Game>? games;

  const CharacterGamesSection({
    super.key,
    required this.character,
    this.games,
  });

  @override
  State<CharacterGamesSection> createState() => _CharacterGamesSectionState();
}

class _CharacterGamesSectionState extends State<CharacterGamesSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Game> _displayGames = [];
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGames();
    _setupTabController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeGames() {
    // 🆕 UPDATED: Prefer character.games over passed games parameter
    if (widget.character.hasLoadedGames) {
      _displayGames = widget.character.games!;
      print(
          '🎮 CharacterGamesSection: Using character.games (${_displayGames.length} games)');
    } else if (widget.games != null && widget.games!.isNotEmpty) {
      _displayGames = widget.games!;
      print(
          '🎮 CharacterGamesSection: Using passed games parameter (${_displayGames.length} games)');
    } else {
      // No games loaded yet - let parent component handle loading
      print('🎮 CharacterGamesSection: No games available yet');
      _displayGames = [];
    }
  }

  void _setupTabController() {
    final tabCount = _getTabCount();
    _tabController = TabController(length: tabCount, vsync: this);
  }

  int _getTabCount() {
    if (_displayGames.isEmpty) return 1;

    // Create tabs based on game categories
    final tabs = <String>[];

    tabs.add('All Games');

    // Add tabs for different platforms if we have many games
    if (_displayGames.length > 5) {
      final platforms = _displayGames
          .expand((game) => game.platforms)
          .map((platform) => platform.name)
          .toSet()
          .take(3)
          .toList();

      if (platforms.isNotEmpty) {
        tabs.addAll(platforms);
      }
    }

    return tabs.length;
  }

  @override
  Widget build(BuildContext context) {
    // 🆕 UPDATED: Re-initialize when widget updates (e.g., when games are loaded)
    final hasGamesNow = (widget.character.hasLoadedGames) ||
        (widget.games != null && widget.games!.isNotEmpty);

    if (hasGamesNow && _displayGames.isEmpty) {
      _initializeGames();
      _setupTabController();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            if (_isLoading)
              _buildLoadingState()
            else if (_displayGames.isEmpty && widget.character.hasGames)
              _buildLoadingGamesState()
            else if (_displayGames.isEmpty)
              _buildEmptyState()
            else
              _buildGamesContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.videogame_asset,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Featured Games',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_displayGames.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          if (_displayGames.length > 6)
            TextButton.icon(
              onPressed: _showAllGames,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGamesContent() {
    return Column(
      children: [
        if (_getTabCount() > 1) _buildTabBar(),
        SizedBox(
          height: 280,
          child: _getTabCount() > 1 ? _buildTabBarView() : _buildGamesList(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.green,
        unselectedLabelColor: Colors.grey.shade600,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.green.withOpacity(0.1),
        ),
        tabs: _buildTabs(),
      ),
    );
  }

  List<Widget> _buildTabs() {
    final tabs = <Widget>[
      const Tab(text: 'All Games'),
    ];

    if (_displayGames.length > 5) {
      final platforms = _displayGames
          .expand((game) => game.platforms)
          .map((platform) => platform.name)
          .toSet()
          .take(3)
          .toList();

      for (final platform in platforms) {
        tabs.add(Tab(text: platform));
      }
    }

    return tabs;
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGamesList(), // All games
        ..._buildPlatformSpecificLists(),
      ],
    );
  }

  List<Widget> _buildPlatformSpecificLists() {
    if (_displayGames.length <= 5) return [];

    final platforms = _displayGames
        .expand((game) => game.platforms)
        .map((platform) => platform.name)
        .toSet()
        .take(3)
        .toList();

    return platforms.map((platform) {
      final platformGames = _displayGames
          .where((game) => game.platforms.any((p) => p.name == platform))
          .toList();
      return _buildGamesList(games: platformGames);
    }).toList();
  }

  Widget _buildGamesList({List<Game>? games}) {
    final gamesToShow = games ?? _displayGames.take(6).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gamesToShow.length,
        itemBuilder: (context, index) {
          final game = gamesToShow[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == gamesToShow.length - 1 ? 0 : 12,
            ),
            child: SizedBox(
              width: 160,
              child: GameCard(
                game: game,
                onTap: () => Navigations.navigateToGameDetail(game.id, context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 12),
            Text('Loading character games...'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGamesState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 12),
            Text('Loading character games...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No Games Found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'This character doesn\'t appear in any games yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAllGames() {
    // TODO: Navigate to a full games list screen for this character
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.character.name} Games'),
        content: Text(
            'Show all ${_displayGames.length} games featuring this character.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
