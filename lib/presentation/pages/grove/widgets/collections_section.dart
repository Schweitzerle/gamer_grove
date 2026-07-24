import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/presentation/blocs/user_collections/user_collections_bloc.dart';
import 'package:gamer_grove/presentation/pages/collections/collection_create_gate.dart';
import 'package:gamer_grove/presentation/pages/collections/collection_detail_page.dart';
import 'package:gamer_grove/presentation/pages/collections/collections_page.dart';
import 'package:gamer_grove/presentation/pages/collections/widgets/collection_form_sheet.dart';
import 'package:gamer_grove/presentation/widgets/sections/section_frame.dart';

/// Height of the horizontal collection strip.
const double _stripHeight = 116;

/// Grove entry point for custom collections: a horizontal strip of the user's
/// collections, "View All" into the full list, and a create action when empty.
///
/// Reads the [UserCollectionsBloc] provided by the Grove page, so tapping
/// through to a collection keeps counts in sync with the rest of the app.
class CollectionsSection extends StatelessWidget {
  const CollectionsSection({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCollectionsBloc, UserCollectionsState>(
      builder: (context, state) {
        return SectionFrame(
          title: 'My Collections',
          subtitle: 'Your own lists, your own rules',
          icon: Icons.collections_bookmark_rounded,
          onViewAll: switch (state) {
            UserCollectionsLoaded(:final collections)
                when collections.isNotEmpty =>
              () => _openAll(context),
            _ => null,
          },
          child: switch (state) {
            UserCollectionsLoaded(:final collections) => collections.isEmpty
                ? _CollectionsEmpty(userId: userId)
                : _CollectionStrip(collections: collections),
            UserCollectionsError(:final message) => _SectionMessage(message),
            _ => const _CollectionsSkeleton(),
          },
        );
      },
    );
  }

  void _openAll(BuildContext context) {
    unawaited(
      Navigator.of(context).push(
        CollectionsPage.routeWith(
          userId: userId,
          collectionsBloc: context.read<UserCollectionsBloc>(),
        ),
      ),
    );
  }
}

class _CollectionStrip extends StatelessWidget {
  const _CollectionStrip({required this.collections});

  final List<UserCollection> collections;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _stripHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
        ),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: _CollectionCard(
              collection: collection,
              onTap: () => unawaited(
                Navigator.of(context).push(
                  CollectionDetailPage.route(
                    collection: collection,
                    collectionsBloc: context.read<UserCollectionsBloc>(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection, required this.onTap});

  final UserCollection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = collection.gameCount;
    return Semantics(
      button: true,
      label: '${collection.name}, '
          '${count == 1 ? '1 game' : '$count games'}',
      child: SizedBox(
        width: 170,
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: theme.colorScheme.surfaceContainerHighest,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.collections_bookmark_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const Spacer(),
                  Text(
                    collection.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == 1 ? '1 game' : '$count games',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionsEmpty extends StatelessWidget {
  const _CollectionsEmpty({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group games your way — "Cozy games", "Backlog 2026", anything.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => _create(context),
            icon: const Icon(Icons.add),
            label: const Text('Create collection'),
          ),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final bloc = context.read<UserCollectionsBloc>();
    // Empty section means zero collections, so the free limit cannot be hit —
    // the gate still runs so entitlement handling stays in one place.
    if (!await ensureCanCreateCollection(context, 0)) return;
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

class _CollectionsSkeleton extends StatelessWidget {
  const _CollectionsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: _stripHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
        ),
        itemCount: 3,
        itemBuilder: (context, _) => Padding(
          padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
          child: Container(
            width: 170,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
