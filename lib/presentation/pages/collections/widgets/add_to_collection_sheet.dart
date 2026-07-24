import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/usecases/user_collection/add_game_to_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_collection_ids_containing_game_use_case.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/user_collections/user_collections_bloc.dart';
import 'package:gamer_grove/presentation/pages/collections/collection_create_gate.dart';
import 'package:gamer_grove/presentation/pages/collections/widgets/collection_form_sheet.dart';

/// Result of the add-to-collection sheet.
///
/// The sheet closes as soon as the write finishes, so its own context is gone
/// by then; the caller (which still has a live context) shows the feedback.
class AddToCollectionOutcome {
  const AddToCollectionOutcome.added(this.collectionName) : error = null;
  const AddToCollectionOutcome.failed(this.collectionName, this.error);

  final String collectionName;
  final String? error;

  bool get isAdded => error == null;
}

/// Opens the "Add to collection" sheet for [gameId].
///
/// Tapping a collection performs the (idempotent) add, then closes the sheet
/// and returns the outcome. A "New collection" action creates one inline; the
/// user can then tap it.
Future<AddToCollectionOutcome?> showAddToCollectionSheet(
  BuildContext context, {
  required String userId,
  required int gameId,
  required String gameName,
}) {
  return showModalBottomSheet<AddToCollectionOutcome>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider<UserCollectionsBloc>(
      create: (_) => sl<UserCollectionsBloc>()..add(LoadCollections(userId)),
      child: _AddToCollectionSheet(
        userId: userId,
        gameId: gameId,
        gameName: gameName,
      ),
    ),
  );
}

class _AddToCollectionSheet extends StatefulWidget {
  const _AddToCollectionSheet({
    required this.userId,
    required this.gameId,
    required this.gameName,
  });

  final String userId;
  final int gameId;
  final String gameName;

  @override
  State<_AddToCollectionSheet> createState() => _AddToCollectionSheetState();
}

class _AddToCollectionSheetState extends State<_AddToCollectionSheet> {
  /// Collection currently being written to; blocks further taps meanwhile.
  String? _addingToId;

  /// Collections that already hold this game — shown as added, not tappable.
  Set<String> _alreadyIn = const {};

  @override
  void initState() {
    super.initState();
    unawaited(_loadMembership());
  }

  /// Membership is advisory: if the lookup fails the sheet stays fully usable,
  /// and adding again is a no-op server-side anyway.
  Future<void> _loadMembership() async {
    final result = await sl<GetCollectionIdsContainingGameUseCase>()(
      GetCollectionIdsContainingGameParams(
        userId: widget.userId,
        gameId: widget.gameId,
      ),
    );
    if (!mounted) return;
    result.fold(
      (_) {},
      (ids) => setState(() => _alreadyIn = ids.toSet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add to collection',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.gameName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: const Text('New collection'),
              onTap:
                  _addingToId != null ? null : () => _createCollection(context),
            ),
            const Divider(height: 8),
            Flexible(
              child: BlocBuilder<UserCollectionsBloc, UserCollectionsState>(
                builder: (context, state) {
                  return switch (state) {
                    UserCollectionsLoaded(:final collections) => collections
                            .isEmpty
                        ? _hint(theme, 'No collections yet — create one above.')
                        : ListView(
                            shrinkWrap: true,
                            children: [
                              for (final c in collections)
                                _CollectionTile(
                                  name: c.name,
                                  gameCount: c.gameCount,
                                  contains: _alreadyIn.contains(c.id),
                                  adding: _addingToId == c.id,
                                  // Any add in flight locks the whole list so
                                  // a second tap cannot race the first.
                                  onTap: _addingToId != null
                                      ? null
                                      : () => _addTo(c.id, c.name),
                                ),
                            ],
                          ),
                    UserCollectionsError(:final message) =>
                      _hint(theme, message),
                    _ => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint(ThemeData theme, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );

  /// Writes the game into [collectionId], then closes the sheet with the
  /// outcome. The write runs through the use case rather than the sheet's bloc
  /// so it cannot outlive the bloc this sheet owns, and so the feedback the
  /// caller shows reflects what actually happened.
  Future<void> _addTo(String collectionId, String name) async {
    if (_addingToId != null || _alreadyIn.contains(collectionId)) return;
    setState(() => _addingToId = collectionId);
    unawaited(HapticFeedback.lightImpact());

    final result = await sl<AddGameToCollectionUseCase>()(
      AddGameToCollectionParams(
        collectionId: collectionId,
        gameId: widget.gameId,
      ),
    );
    if (!mounted) return;

    final outcome = result.fold(
      (failure) => AddToCollectionOutcome.failed(name, failure.message),
      (_) => AddToCollectionOutcome.added(name),
    );
    Navigator.of(context).pop(outcome);
  }

  Future<void> _createCollection(BuildContext context) async {
    final bloc = context.read<UserCollectionsBloc>();
    final state = bloc.state;
    final currentCount = state is UserCollectionsLoaded ? state.count : 0;

    if (!await ensureCanCreateCollection(context, currentCount)) return;
    if (!context.mounted) return;

    final result = await showCollectionFormSheet(context);
    if (result == null) return;

    trackCollectionCreate();
    bloc.add(
      CreateCollection(
        userId: widget.userId,
        name: result.name,
        description: result.description,
      ),
    );
  }
}

/// One collection row in the sheet.
///
/// A collection that already holds the game is shown as added and is not
/// tappable — re-adding is a server-side no-op, so offering it only produced a
/// success toast for something that did not happen.
class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.name,
    required this.gameCount,
    required this.contains,
    required this.adding,
    required this.onTap,
  });

  final String name;
  final int gameCount;
  final bool contains;
  final bool adding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle =
        contains ? 'Already in this collection' : _gameCountLabel(gameCount);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: !contains && onTap != null,
      leading: Icon(
        contains
            ? Icons.check_circle_rounded
            : Icons.collections_bookmark_rounded,
        color: contains ? scheme.primary : null,
      ),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
      trailing: adding
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: contains ? null : onTap,
    );
  }

  static String _gameCountLabel(int count) =>
      count == 1 ? '1 game' : '$count games';
}
