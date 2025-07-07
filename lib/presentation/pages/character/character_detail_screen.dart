// lib/presentation/pages/characters/character_detail_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/character/character.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/repositories/game_repository.dart';
import '../../../injection_container.dart';
import 'widgets/character_info_card.dart';
import 'widgets/character_description_section.dart';
import 'widgets/character_games_section.dart';
import 'widgets/character_details_accordion.dart';

class CharacterDetailScreen extends StatefulWidget {
  final Character character;
  final List<Game>? characterGames;

  const CharacterDetailScreen({
    super.key,
    required this.character,
    this.characterGames,
  });

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isHeaderCollapsed = false;

  // Game loading state
  List<Game>? _loadedGames;
  bool _isLoadingGames = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadedGames = widget.characterGames;
    _logCharacterData();

    // Debug logging
    print('🔧 DEBUG initState: _loadedGames is null: ${_loadedGames == null}');
    print('🔧 DEBUG initState: character.hasGames: ${widget.character.hasGames}');
    print('🔧 DEBUG initState: character.gameIds: ${widget.character.gameIds}');

    // Load games if not provided and character has games
    if (_loadedGames == null && widget.character.hasGames) {
      print('🚀 DEBUG: Triggering _loadCharacterGames()...');
      _loadCharacterGames();
    } else {
      print('❌ DEBUG: NOT triggering _loadCharacterGames() because:');
      print('   - _loadedGames is null: ${_loadedGames == null}');
      print('   - character.hasGames: ${widget.character.hasGames}');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isCollapsed = _scrollController.offset > 200;
      if (isCollapsed != _isHeaderCollapsed) {
        setState(() {
          _isHeaderCollapsed = isCollapsed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Character Info Card (floating)
                CharacterInfoCard(
                  key: ValueKey('info_${_loadedGames?.length ?? 0}'),
                  character: widget.character,
                  loadedGamesCount: _loadedGames?.length,
                ),
                const SizedBox(height: 20),

                // Description Section
                CharacterDescriptionSection(character: widget.character),
                const SizedBox(height: 20),

                // Character Games Section
                if (widget.character.hasGames)
                  Column(
                    children: [
                      CharacterGamesSection(
                        key: ValueKey('games_${_loadedGames?.length ?? 0}'),
                        character: widget.character,
                        games: widget.character.hasLoadedGames
                            ? widget.character.games
                            : _loadedGames,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                // Character Details Accordion
                CharacterDetailsAccordion(character: widget.character),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: _isHeaderCollapsed
            ? Text(
          widget.character.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black54,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        )
            : null,
        background: _buildHeroImage(),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
      child: widget.character.hasImage
          ? CachedNetworkImage(
        imageUrl: widget.character.largeUrl ?? widget.character.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.purple.withOpacity(0.1),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.purple),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackHero(),
      )
          : _buildFallbackHero(),
    );
  }

  Widget _buildFallbackHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.deepPurple.withOpacity(0.6),
            Colors.indigo.withOpacity(0.4),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              widget.character.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _loadCharacterGames() async {
    print('🚀 _loadCharacterGames() STARTED');

    setState(() {
      _isLoadingGames = true;
    });

    try {
      print('🎮 Loading games for character: ${widget.character.name}');
      print('📋 Game IDs: ${widget.character.gameIds}');

      // Use the existing repository method to load games
      final gameRepository = sl<GameRepository>();
      print('📡 Calling gameRepository.getGamesByIds...');
      final result = await gameRepository.getGamesByIds(widget.character.gameIds);

      result.fold(
            (failure) {
          print('❌ Error loading character games: ${failure.message}');
          if (mounted) {
            setState(() {
              _isLoadingGames = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load games: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
            (games) {
          print('✅ Successfully loaded ${games.length} games for character');
          for (var game in games.take(3)) {
            print('   • ${game.name}');
          }
          if (games.length > 3) {
            print('   ... and ${games.length - 3} more games');
          }

          if (mounted) {
            setState(() {
              _isLoadingGames = false;
              _loadedGames = games;
            });

            // Update log with loaded games
            _logCharacterDataWithGames(games);
          }
        },
      );
    } catch (e) {
      print('❌ Exception loading character games: $e');
      if (mounted) {
        setState(() {
          _isLoadingGames = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load games: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logCharacterData() {
    print('\n=== 🎭 CHARACTER DETAIL SCREEN LOADED ===');
    print('🎯 Character: ${widget.character.name} (ID: ${widget.character.id})');

    // Basic info
    print('📝 Description: ${widget.character.hasDescription ? 'Available' : 'Not available'}');
    print('🏷️ Alternative Names: ${widget.character.akas.length}');

    // Identity
    print('👤 Gender: ${widget.character.displayGender}');
    print('🧬 Species: ${widget.character.displaySpecies}');
    print('🌍 Country: ${widget.character.countryName ?? 'Unknown'}');

    // Images
    if (widget.character.hasImage) {
      print('🖼️ Image: ✅ Available');
      print('   🔗 URL: ${widget.character.imageUrl}');
    } else {
      print('🖼️ Image: ❌ Fallback gradient will be shown');
    }

    // Games
    print('🎮 Game IDs: ${widget.character.gameIds.length}');
    if (widget.character.hasLoadedGames) {
      print('   📱 Loaded Games: ✅ ${widget.character.loadedGameCount}');
      for (var i = 0; i < widget.character.games!.length && i < 3; i++) {
        print('   • ${widget.character.games![i].name}');
      }
      if (widget.character.games!.length > 3) {
        print('   ... and ${widget.character.games!.length - 3} more games');
      }
    } else if (_loadedGames != null) {
      print('   📱 Manually Loaded Games: ✅ ${_loadedGames!.length}');
      for (var i = 0; i < _loadedGames!.length && i < 3; i++) {
        print('   • ${_loadedGames![i].name}');
      }
      if (_loadedGames!.length > 3) {
        print('   ... and ${_loadedGames!.length - 3} more games');
      }
    } else {
      print('   📱 Games Data: ${_isLoadingGames ? 'Loading...' : 'Will be loaded'}');
      // Debug loading trigger
      print('   🔧 Debug: _loadedGames == null: ${_loadedGames == null}');
      print('   🔧 Debug: character.hasGames: ${widget.character.hasGames}');
      print('   🔧 Debug: Will trigger _loadCharacterGames: ${_loadedGames == null && widget.character.hasGames}');
    }

    print('=== END CHARACTER DETAIL LOG ===\n');
  }

  // Log character data after games are loaded
  void _logCharacterDataWithGames(List<Game> games) {
    print('\n=== 🎮 CHARACTER GAMES LOADED ===');
    print('🎯 Character: ${widget.character.name}');
    print('✅ Successfully loaded ${games.length} games:');
    for (var i = 0; i < games.length && i < 5; i++) {
      print('   • ${games[i].name}');
    }
    if (games.length > 5) {
      print('   ... and ${games.length - 5} more games');
    }
    print('📱 CharacterGamesSection will now display these games');
    print('=== END GAMES LOADING LOG ===\n');
  }
}