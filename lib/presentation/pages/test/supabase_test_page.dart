// presentation/pages/test/supabase_test_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/remote/supabase/supabase_remote_datasource.dart';
import '../../../data/models/user_model.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';

class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({super.key});

  @override
  State<SupabaseTestPage> createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  final SupabaseRemoteDataSource _supabaseDataSource =
      sl<SupabaseRemoteDataSource>();

  // Controllers
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _gameIdController = TextEditingController(text: '1942'); // Witcher 3 ID
  final _ratingController = TextEditingController(text: '8.5');
  final _searchController = TextEditingController();
  final _targetUserController = TextEditingController();
  final _topGamesController = TextEditingController(text: '1942,1020,1942');

  // State
  String _testResults = '';
  bool _isLoading = false;
  String? _currentUserId;
  UserModel? _currentUserProfile;
  List<UserModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    checkAuthStatus();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _gameIdController.dispose();
    _ratingController.dispose();
    _searchController.dispose();
    _targetUserController.dispose();
    _topGamesController.dispose();
    super.dispose();
  }

  void _getCurrentUser() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
      _currentUserProfile = authState.user as UserModel?;
      _usernameController.text = authState.user.username;
      _bioController.text = authState.user.bio ?? '';
    }
  }

  void _addTestResult(String result) {
    setState(() {
      _testResults +=
          '${DateTime.now().toString().substring(11, 19)}: $result\n';
    });
  }

  // In eurer Supabase Test Page hinzufügen:
  void checkAuthStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    print('🔐 Current User: ${user?.id}');
    print('🔐 User Email: ${user?.email}');
    print('🔐 Session valid: ${user != null}');

    // JWT Token prüfen
    final session = Supabase.instance.client.auth.currentSession;
    print('🔐 Session: ${session?.accessToken != null}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Integration Test'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _testResults = '';
              });
            },
            tooltip: 'Clear Results',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current User Info
            _buildCurrentUserSection(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Profile Management Tests
            _buildProfileTestSection(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Game Actions Tests
            _buildGameActionsSection(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Social Features Tests
            _buildSocialFeaturesSection(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Top Games Tests
            _buildTopGamesSection(),
            const SizedBox(height: AppConstants.paddingLarge),

            // Test Results
            _buildTestResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentUserSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current User Info',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            if (_currentUserId != null) ...[
              Text('User ID: $_currentUserId'),
              Text('Username: ${_currentUserProfile?.username ?? "Unknown"}'),
              Text('Email: ${_currentUserProfile?.email ?? "Unknown"}'),
              Text('Bio: ${_currentUserProfile?.bio ?? "No bio"}'),
              Text(
                  'Wishlist Count: ${_currentUserProfile?.wishlistGameIds.length ?? 0}'),
              Text(
                  'Rated Games: ${_currentUserProfile?.ratedGameIds.length ?? 0}'),
              Text('Following: ${_currentUserProfile?.followingCount ?? 0}'),
              Text('Followers: ${_currentUserProfile?.followersCount ?? 0}'),
            ] else ...[
              const Text('No user logged in'),
            ],
            const SizedBox(height: AppConstants.paddingSmall),
            ElevatedButton.icon(
              onPressed: _refreshUserProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh User Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Management Tests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testUpdateProfile,
                  icon: const Icon(Icons.person),
                  label: const Text('Update Profile'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetProfile,
                  icon: const Icon(Icons.download),
                  label: const Text('Get Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Actions Tests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gameIdController,
                    decoration: const InputDecoration(
                      labelText: 'Game ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ratingController,
                    decoration: const InputDecoration(
                      labelText: 'Rating (0-10)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testToggleWishlist,
                  icon: const Icon(Icons.favorite),
                  label: const Text('Toggle Wishlist'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testToggleRecommended,
                  icon: const Icon(Icons.thumb_up),
                  label: const Text('Toggle Recommended'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testRateGame,
                  icon: const Icon(Icons.star),
                  label: const Text('Rate Game'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetWishlist,
                  icon: const Icon(Icons.list),
                  label: const Text('Get Wishlist'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetRecommended,
                  icon: const Icon(Icons.recommend),
                  label: const Text('Get Recommended'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetRatings,
                  icon: const Icon(Icons.star_rate),
                  label: const Text('Get Ratings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialFeaturesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social Features Tests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _targetUserController,
                    decoration: const InputDecoration(
                      labelText: 'Target User ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testSearchUsers,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Users'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testFollowUser,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Follow User'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testUnfollowUser,
                  icon: const Icon(Icons.person_remove),
                  label: const Text('Unfollow User'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetFollowers,
                  icon: const Icon(Icons.people),
                  label: const Text('Get Followers'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetFollowing,
                  icon: const Icon(Icons.people_outline),
                  label: const Text('Get Following'),
                ),
              ],
            ),

            // Search Results
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Search Results:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...(_searchResults.take(5).map((user) => ListTile(
                    title: Text(user.username),
                    subtitle: Text(user.id),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        _targetUserController.text = user.id;
                        _addTestResult('Target user set to: ${user.username}');
                      },
                    ),
                    dense: true,
                  ))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopGamesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Games Tests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            TextField(
              controller: _topGamesController,
              decoration: const InputDecoration(
                labelText: 'Top 3 Game IDs (comma separated)',
                border: OutlineInputBorder(),
                helperText: 'Example: 1942,1020,119171',
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testUpdateTopGames,
                  icon: const Icon(Icons.star),
                  label: const Text('Update Top Games'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testGetTopGames,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Get Top Games'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.terminal,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _testResults.isEmpty
                      ? 'No test results yet...'
                      : _testResults,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Test Methods
  Future<void> _refreshUserProfile() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final profile = await _supabaseDataSource.getUserProfile(_currentUserId!);
      setState(() {
        _currentUserProfile = profile;
      });
      _addTestResult('✅ User profile refreshed successfully');
    } catch (e) {
      _addTestResult('❌ Failed to refresh profile: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testUpdateProfile() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final updates = <String, dynamic>{};
      if (_usernameController.text.isNotEmpty) {
        updates['username'] = _usernameController.text;
      }
      if (_bioController.text.isNotEmpty) {
        updates['bio'] = _bioController.text;
      }

      final updatedProfile =
          await _supabaseDataSource.updateUserProfile(userId: _currentUserId!);
      setState(() {
        _currentUserProfile = updatedProfile;
      });
      _addTestResult('✅ Profile updated successfully');
    } catch (e) {
      _addTestResult('❌ Failed to update profile: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testGetProfile() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final profile = await _supabaseDataSource.getUserProfile(_currentUserId!);
      _addTestResult('✅ Profile retrieved: ${profile.username}');
    } catch (e) {
      _addTestResult('❌ Failed to get profile: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testToggleWishlist() async {
    if (_currentUserId == null) return;

    final gameId = int.tryParse(_gameIdController.text);
    if (gameId == null) {
      _addTestResult('❌ Invalid game ID');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _supabaseDataSource.toggleWishlist(gameId, _currentUserId!);
      _addTestResult('✅ Wishlist toggled for game $gameId');
    } catch (e) {
      _addTestResult('❌ Failed to toggle wishlist: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testToggleRecommended() async {
    if (_currentUserId == null) return;

    final gameId = int.tryParse(_gameIdController.text);
    if (gameId == null) {
      _addTestResult('❌ Invalid game ID');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _supabaseDataSource.toggleRecommended(gameId, _currentUserId!);
      _addTestResult('✅ Recommendation toggled for game $gameId');
    } catch (e) {
      _addTestResult('❌ Failed to toggle recommendation: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testRateGame() async {
    if (_currentUserId == null) return;

    final gameId = int.tryParse(_gameIdController.text);
    final rating = double.tryParse(_ratingController.text);

    if (gameId == null || rating == null) {
      _addTestResult('❌ Invalid game ID or rating');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _supabaseDataSource.rateGame(gameId, _currentUserId!, rating);
      _addTestResult('✅ Game $gameId rated: $rating/10');
    } catch (e) {
      _addTestResult('❌ Failed to rate game: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testGetWishlist() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final wishlistIds =
          await _supabaseDataSource.getUserWishlistIds(_currentUserId!);
      _addTestResult('✅ Wishlist retrieved: ${wishlistIds.length} games');
      _addTestResult(
          '   Game IDs: ${wishlistIds.take(5).join(", ")}${wishlistIds.length > 5 ? "..." : ""}');
    } catch (e) {
      _addTestResult('❌ Failed to get wishlist: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testGetRecommended() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final recommendedIds =
          await _supabaseDataSource.getUserRecommendedIds(_currentUserId!);
      _addTestResult(
          '✅ Recommended games retrieved: ${recommendedIds.length} games');
      _addTestResult(
          '   Game IDs: ${recommendedIds.take(5).join(", ")}${recommendedIds.length > 5 ? "..." : ""}');
    } catch (e) {
      _addTestResult('❌ Failed to get recommended games: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testGetRatings() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final ratings = await _supabaseDataSource.getUserRatings(_currentUserId!);
      _addTestResult('✅ Ratings retrieved: ${ratings.length} games');
      final sample =
          ratings.entries.take(3).map((e) => '${e.key}:${e.value}').join(', ');
      if (sample.isNotEmpty) {
        _addTestResult('   Sample: $sample${ratings.length > 3 ? "..." : ""}');
      }
    } catch (e) {
      _addTestResult('❌ Failed to get ratings: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testSearchUsers() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _addTestResult('❌ Search query is empty');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final users = await _supabaseDataSource.searchUsers(query: query);
      setState(() {
        _searchResults = users;
      });
      _addTestResult('✅ User search completed: ${users.length} results');
      if (users.isNotEmpty) {
        _addTestResult('   First result: ${users.first.username}');
      }
    } catch (e) {
      _addTestResult('❌ Failed to search users: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testFollowUser() async {
    if (_currentUserId == null) return;

    final targetId = _targetUserController.text.trim();
    if (targetId.isEmpty) {
      _addTestResult('❌ Target user ID is empty');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _supabaseDataSource.followUser(
          currentUserId: _currentUserId!, targetUserId: targetId);
      _addTestResult('✅ Successfully followed user: $targetId');
    } catch (e) {
      _addTestResult('❌ Failed to follow user: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testUnfollowUser() async {
    if (_currentUserId == null) return;

    final targetId = _targetUserController.text.trim();
    if (targetId.isEmpty) {
      _addTestResult('❌ Target user ID is empty');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _supabaseDataSource.unfollowUser(
          currentUserId: _currentUserId!, targetUserId: targetId);
      _addTestResult('✅ Successfully unfollowed user: $targetId');
    } catch (e) {
      _addTestResult('❌ Failed to unfollow user: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testGetFollowers() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final followers =
          await _supabaseDataSource.getUserFollowers(userId: _currentUserId!);
      _addTestResult('✅ Followers retrieved: ${followers.length}');
      if (followers.isNotEmpty) {
        _addTestResult(
            '   IDs: ${followers.take(3).join(", ")}${followers.length > 3 ? "..." : ""}');
      }
    } catch (e) {
      _addTestResult('❌ Failed to get followers: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testGetFollowing() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final following =
          await _supabaseDataSource.getUserFollowing(userId: _currentUserId!);
      _addTestResult('✅ Following retrieved: ${following.length}');
      if (following.isNotEmpty) {
        _addTestResult(
            '   IDs: ${following.take(3).join(", ")}${following.length > 3 ? "..." : ""}');
      }
    } catch (e) {
      _addTestResult('❌ Failed to get following: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testUpdateTopGames() async {
    if (_currentUserId == null) return;

    final gameIdsString = _topGamesController.text.trim();
    if (gameIdsString.isEmpty) {
      _addTestResult('❌ Game IDs are empty');
      return;
    }

    try {
      final gameIds = gameIdsString
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (gameIds.length > 3) {
        _addTestResult('❌ Maximum 3 games allowed');
        return;
      }

      // ✅ Duplikate entfernen
      final uniqueGameIds = gameIds.toSet().toList();
      if (uniqueGameIds.length != gameIds.length) {
        _addTestResult(
            '⚠️ Duplicate games removed. Using: ${uniqueGameIds.join(", ")}');
      }

      setState(() => _isLoading = true);
      await _supabaseDataSource.updateTopThreeGames(
          userId: _currentUserId!, gameIds: uniqueGameIds);
      _addTestResult('✅ Top games updated: ${uniqueGameIds.join(", ")}');
    } catch (e) {
      _addTestResult('❌ Failed to update top games: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testGetTopGames() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    try {
      final topGames = await _supabaseDataSource.getUserTopThreeGames(
          userId: _currentUserId!);
      _addTestResult('✅ Top games retrieved: ${topGames.length}');
      if (topGames.isNotEmpty) {
        _addTestResult('   Game IDs: ${topGames.join(", ")}');
      }
    } catch (e) {
      _addTestResult('❌ Failed to get top games: $e');
    }
    setState(() => _isLoading = false);
  }
}
