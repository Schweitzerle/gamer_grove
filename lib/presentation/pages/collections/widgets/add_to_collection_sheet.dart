import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/services/toast_service.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/user_collections/user_collections_bloc.dart';
import 'package:gamer_grove/presentation/pages/collections/collection_create_gate.dart';
import 'package:gamer_grove/presentation/pages/collections/widgets/collection_form_sheet.dart';

/// Opens the "Add to collection" sheet for [gameId].
///
/// Tapping a collection adds the game (idempotent) and closes the sheet. A
/// "New collection" action creates one inline; the user can then tap it.
Future<void> showAddToCollectionSheet(
  BuildContext context, {
  required String userId,
  required int gameId,
  required String gameName,
}) {
  return showModalBottomSheet<void>(
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

class _AddToCollectionSheet extends StatelessWidget {
  const _AddToCollectionSheet({
    required this.userId,
    required this.gameId,
    required this.gameName,
  });

  final String userId;
  final int gameId;
  final String gameName;

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
              gameName,
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
              onTap: () => _createCollection(context),
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
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.collections_bookmark_rounded,
                                  ),
                                  title: Text(
                                    c.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    c.gameCount == 1
                                        ? '1 game'
                                        : '${c.gameCount} games',
                                  ),
                                  onTap: () => _addTo(context, c.id, c.name),
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

  void _addTo(BuildContext context, String collectionId, String name) {
    context.read<UserCollectionsBloc>().add(
          AddGameToCollection(collectionId: collectionId, gameId: gameId),
        );
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    GamerGroveToastService.showSuccess(
      context,
      title: 'Added to $name',
      message: gameName,
    );
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
        userId: userId,
        name: result.name,
        description: result.description,
      ),
    );
  }
}
