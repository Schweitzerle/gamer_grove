import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/services/toast_service.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/user_collections/user_collections_bloc.dart';
import 'package:gamer_grove/presentation/pages/collections/collection_detail_page.dart';
import 'package:gamer_grove/presentation/pages/collections/widgets/collection_form_sheet.dart';

/// Lists the signed-in user's custom collections and lets them create, rename,
/// delete and open collections.
class CollectionsPage extends StatelessWidget {
  const CollectionsPage({required this.userId, super.key});

  final String userId;

  /// Route that provides the bloc and loads the user's collections.
  static Route<void> route(String userId) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => sl<UserCollectionsBloc>()..add(LoadCollections(userId)),
        child: CollectionsPage(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Collections')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: BlocConsumer<UserCollectionsBloc, UserCollectionsState>(
        listenWhen: (prev, curr) =>
            curr is UserCollectionsLoaded && curr.actionError != null,
        listener: (context, state) {
          if (state is UserCollectionsLoaded && state.actionError != null) {
            GamerGroveToastService.showError(
              context,
              title: 'Something went wrong',
              message: state.actionError!,
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            UserCollectionsInitial() ||
            UserCollectionsLoading() =>
              const Center(child: CircularProgressIndicator()),
            UserCollectionsError(:final message) =>
              _ErrorView(message: message, userId: userId),
            UserCollectionsLoaded(:final collections) => collections.isEmpty
                ? _EmptyView(onCreate: () => _create(context))
                : _CollectionsList(collections: collections),
          };
        },
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final bloc = context.read<UserCollectionsBloc>();
    final result = await showCollectionFormSheet(context);
    if (result == null) return;
    bloc.add(
      CreateCollection(
        userId: userId,
        name: result.name,
        description: result.description,
      ),
    );
  }
}

class _CollectionsList extends StatelessWidget {
  const _CollectionsList({required this.collections});

  final List<UserCollection> collections;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: collections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _CollectionTile(collection: collections[index]),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.collection});

  final UserCollection collection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle =
        collection.gameCount == 1 ? '1 game' : '${collection.gameCount} games';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.collections_bookmark_rounded,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          collection.name,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          collection.hasDescription ? collection.description! : subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _CollectionMenu(collection: collection),
        onTap: () => Navigator.of(context).push(
          CollectionDetailPage.route(
            collection: collection,
            collectionsBloc: context.read<UserCollectionsBloc>(),
          ),
        ),
      ),
    );
  }
}

class _CollectionMenu extends StatelessWidget {
  const _CollectionMenu({required this.collection});

  final UserCollection collection;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserCollectionsBloc>();
    return PopupMenuButton<String>(
      tooltip: 'Collection options',
      onSelected: (value) async {
        switch (value) {
          case 'rename':
            final result = await showCollectionFormSheet(
              context,
              title: 'Edit collection',
              submitLabel: 'Save',
              initialName: collection.name,
              initialDescription: collection.description,
            );
            if (result == null) return;
            bloc.add(
              UpdateCollection(
                collectionId: collection.id,
                name: result.name,
                description: result.description,
              ),
            );
          case 'delete':
            final confirmed = await _confirmDelete(context, collection.name);
            if (confirmed) bloc.add(DeleteCollection(collection.id));
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'rename', child: Text('Rename / edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}

Future<bool> _confirmDelete(BuildContext context, String name) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete collection?'),
      content: Text('"$name" will be permanently deleted. Games stay in your '
          'library.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreate});

  final VoidCallback onCreate;

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
              Icons.collections_bookmark_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No collections yet',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Group games your way — "Cozy games", "Backlog 2026", '
              'anything you like.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create your first collection'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.userId});

  final String message;
  final String userId;

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
            FilledButton(
              onPressed: () => context
                  .read<UserCollectionsBloc>()
                  .add(LoadCollections(userId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
