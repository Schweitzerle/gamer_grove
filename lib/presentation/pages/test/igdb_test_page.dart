// presentation/pages/test/igdb_test_page.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/remote/igdb/idgb_remote_datasource.dart';
import '../../../data/models/game/game_model.dart';
import '../../../injection_container.dart';

class IGDBTestPage extends StatefulWidget {
  const IGDBTestPage({super.key});

  @override
  State<IGDBTestPage> createState() => _IGDBTestPageState();
}

class _IGDBTestPageState extends State<IGDBTestPage> {
  final IGDBRemoteDataSource _igdbDataSource = sl<IGDBRemoteDataSource>();
  final _searchController = TextEditingController();

  bool _isLoading = false;
  String _testResult = '';
  List<GameModel> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IGDB API Test'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Section Header
            Text(
              'IGDB API Integration Test',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // Search Test Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Search Games Test',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),

                    // Search Input
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Game Name',
                        hintText: 'e.g., "The Witcher", "Mario", "Cyberpunk"',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Test Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _testSearch,
                          icon: _isLoading
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Icon(Icons.search),
                          label: const Text('Test Search'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _testPopularGames,
                          icon: const Icon(Icons.trending_up),
                          label: const Text('Popular Games'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _testUpcomingGames,
                          icon: const Icon(Icons.upcoming),
                          label: const Text('Upcoming Games'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _testGameDetails,
                          icon: const Icon(Icons.info),
                          label: const Text('Game Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Test Results Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Test Results',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),

                    if (_testResult.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _testResult,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),

                    if (_searchResults.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'Found ${_searchResults.length} games:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),

                      // Games Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final game = _searchResults[index];
                          return _buildGameCard(game);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(GameModel game) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Game Cover
          Expanded(
            flex: 3,
            child: game.coverUrl != null
                ? Image.network(
              game.coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            )
                : Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.gamepad_rounded, size: 40),
            ),
          ),

          // Game Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (game.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game.rating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                  if (game.genres.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      game.genres.take(2).map((g) => g.name).join(', '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _setTestResult('❌ Please enter a search query');
      return;
    }

    setState(() {
      _isLoading = true;
      _testResult = '🔍 Searching for "$query"...';
      _searchResults.clear();
    });

    try {
      final games = await _igdbDataSource.searchGames(query, 10, 0);

      setState(() {
        _searchResults = games;
        _testResult = '✅ Search completed successfully!\n'
            'Found ${games.length} games for "$query"\n'
            'First game: ${games.isNotEmpty ? games.first.name : "None"}';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Search failed: $e';
        _searchResults.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPopularGames() async {
    setState(() {
      _isLoading = true;
      _testResult = '🔥 Getting popular games...';
      _searchResults.clear();
    });

    try {
      final games = await _igdbDataSource.getPopularGames(10, 0);

      setState(() {
        _searchResults = games;
        _testResult = '✅ Popular games loaded successfully!\n'
            'Found ${games.length} popular games\n'
            'Top game: ${games.isNotEmpty ? games.first.name : "None"}';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Popular games failed: $e';
        _searchResults.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUpcomingGames() async {
    setState(() {
      _isLoading = true;
      _testResult = '🚀 Getting upcoming games...';
      _searchResults.clear();
    });

    try {
      final games = await _igdbDataSource.getUpcomingGames(10, 0);

      setState(() {
        _searchResults = games;
        _testResult = '✅ Upcoming games loaded successfully!\n'
            'Found ${games.length} upcoming games\n'
            'Next game: ${games.isNotEmpty ? games.first.name : "None"}';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Upcoming games failed: $e';
        _searchResults.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGameDetails() async {
    setState(() {
      _isLoading = true;
      _testResult = '🎮 Getting game details (The Witcher 3)...';
      _searchResults.clear();
    });

    try {
      // Test with The Witcher 3: Wild Hunt (ID: 1942)
      final game = await _igdbDataSource.getGameDetails(1942);

      setState(() {
        _searchResults = [game];
        _testResult = '✅ Game details loaded successfully!\n'
            'Game: ${game.name}\n'
            'Rating: ${game.rating?.toStringAsFixed(1) ?? "N/A"}\n'
            'Genres: ${game.genres.map((g) => g.name).join(", ")}\n'
            'Summary length: ${game.summary?.length ?? 0} characters';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Game details failed: $e';
        _searchResults.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setTestResult(String result) {
    setState(() {
      _testResult = result;
    });
  }
}