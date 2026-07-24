import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/services/toast_service.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/usecases/game/get_games_by_ids.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_collection_game_ids_use_case.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/user_collections/user_collections_bloc.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import 'package:gamer_grove/presentation/widgets/game_list_shimmer.dart';

/// Shows the games inside a single custom collection as a grid, with an empty
/// state and two ways to remove a game: an explicit edit mode with a remove
/// badge per card, and long-press as a shortcut for users who know it.
class CollectionDetailPage extends StatefulWidget {
  const CollectionDetailPage({
    required this.collection,
    GetCollectionGameIdsUseCase? getCollectionGameIds,
    GetGamesByIdsUseCase? getGamesByIds,
    super.key,
  })  : _getCollectionGameIds = getCollectionGameIds,
        _getGamesByIds = getGamesByIds;

  final UserCollection collection;
  final GetCollectionGameIdsUseCase? _getCollectionGameIds;
  final GetGamesByIdsUseCase? _getGamesByIds;

  /// Route that keeps the provided collections bloc alive so removing a game
  /// updates the parent list's counts.
  static Route<void> route({
    required UserCollection collection,
    required UserCollectionsBloc collectionsBloc,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: collectionsBloc,
        child: CollectionDetailPage(collection: collection),
      ),
    );
  }

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  late final GetCollectionGameIdsUseCase _getIds =
      widget._getCollectionGameIds ?? sl<GetCollectionGameIdsUseCase>();
  late final GetGamesByIdsUseCase _getGames =
      widget._getGamesByIds ?? sl<GetGamesByIdsUseCase>();

  List<Game> _games = [];
  bool _loading = true;
  String? _error;

  /// Edit mode shows a remove badge on every card. Without it, removing was
  /// long-press only — which testers did not discover.
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final idsResult = await _getIds(
      GetCollectionGameIdsParams(collectionId: widget.collection.id),
    );

    await idsResult.fold(
      (failure) async {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = failure.message;
        });
      },
      (ids) async {
        if (ids.isEmpty) {
          if (!mounted) return;
          setState(() {
            _games = [];
            _loading = false;
          });
          return;
        }
        final gamesResult = await _getGames(GetGamesByIdsParams(gameIds: ids));
        if (!mounted) return;
        gamesResult.fold(
          (failure) => setState(() {
            _loading = false;
            _error = failure.message;
          }),
          (games) {
            // Preserve the collection's stored order.
            final byId = {for (final g in games) g.id: g};
            setState(() {
              _games = [
                for (final id in ids)
                  if (byId[id] != null) byId[id]!,
              ];
              _loading = false;
            });
          },
        );
      },
    );
  }

  Future<void> _removeGame(Game game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from collection?'),
        content: Text('Remove "${game.name}" from '
            '"${widget.collection.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Optimistic local removal; the bloc keeps the parent list's counts fresh.
    setState(() {
      _games = _games.where((g) => g.id != game.id).toList();
      // Nothing left to edit once the last game is gone.
      if (_games.isEmpty) _editing = false;
    });
    context.read<UserCollectionsBloc>().add(
          RemoveGameFromCollection(
            collectionId: widget.collection.id,
            gameId: game.id,
          ),
        );
    HapticFeedback.lightImpact();
    GamerGroveToastService.showInfo(
      context,
      title: 'Removed',
      message: game.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = !_loading && _error == null && _games.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Remove games' : widget.collection.name),
        actions: [
          if (canEdit)
            _editing
                ? TextButton(
                    onPressed: () => setState(() => _editing = false),
                    child: const Text('Done'),
                  )
                : IconButton(
                    tooltip: 'Remove games',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => setState(() => _editing = true),
                  ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const GameListShimmer();
    if (_error != null) {
      return _CollectionDetailError(message: _error!, onRetry: _load);
    }
    if (_games.isEmpty) {
      return const _CollectionDetailEmpty();
    }
    if (!_editing) return _buildGrid();
    return Column(
      children: [
        const _EditModeHint(),
        Expanded(child: _buildGrid()),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
      ),
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final game = _games[index];
        return GestureDetector(
          onLongPress: () => _removeGame(game),
          child: Stack(
            children: [
              GameCard(
                game: game,
                onTap: () => Navigations.navigateToGameDetail(game.id, context),
              ),
              if (_editing)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _RemoveBadge(
                    gameName: game.name,
                    onPressed: () => _removeGame(game),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Explains what the badges do while edit mode is active.
class _EditModeHint extends StatelessWidget {
  const _EditModeHint();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tap the − on a game to remove it from this collection.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Remove control overlaid on a card while the page is in edit mode.
class _RemoveBadge extends StatelessWidget {
  const _RemoveBadge({required this.gameName, required this.onPressed});

  final String gameName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Remove $gameName from collection',
      child: SizedBox(
        // Keeps the touch target at the 48dp platform minimum.
        width: 48,
        height: 48,
        child: Center(
          child: Material(
            color: scheme.errorContainer,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.remove_rounded,
                  size: 20,
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionDetailEmpty extends StatelessWidget {
  const _CollectionDetailEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No games yet',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Open a game and use "Add to collection" to fill this up.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionDetailError extends StatelessWidget {
  const _CollectionDetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
