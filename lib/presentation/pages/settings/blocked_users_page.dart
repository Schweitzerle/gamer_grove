import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/injection_container.dart';

/// The accounts this user has blocked, and the way back.
///
/// Blocking without this screen is a one-way door: the entry point lives on
/// the other person's profile, and a blocked profile is exactly the one you
/// stop visiting. Reversibility has to live somewhere the user can reach
/// without them.
class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({required this.currentUserId, super.key});

  final String currentUserId;

  static Route<void> route(String currentUserId) => MaterialPageRoute<void>(
        builder: (_) => BlockedUsersPage(currentUserId: currentUserId),
      );

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  /// null while loading, so the empty state cannot flash before the first
  /// result arrives.
  List<User>? _blocked;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final outcome = await sl<UserRepository>()
        .getBlockedUsers(userId: widget.currentUserId);
    if (!mounted) return;
    setState(() {
      outcome.fold(
        (failure) => _error = 'Could not load your blocked accounts.',
        (users) {
          _blocked = users;
          _error = null;
        },
      );
    });
  }

  Future<void> _unblock(User user) async {
    final outcome = await sl<UserRepository>().unblockUser(
      currentUserId: widget.currentUserId,
      targetUserId: user.id,
    );
    if (!mounted) return;

    outcome.fold(
      (failure) => _say('Could not unblock ${user.effectiveDisplayName}.'),
      (_) {
        // Unblocking does not restore the follow relationship that blocking
        // dissolved — that was a deliberate action and re-following is the
        // user's to make.
        _say('${user.effectiveDisplayName} is unblocked.');
        setState(() => _blocked?.removeWhere((u) => u.id == user.id));
      },
    );
  }

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked accounts')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final error = _error;
    if (error != null) {
      return _Centered(
        icon: Icons.cloud_off,
        title: error,
        action: FilledButton(
          onPressed: () => unawaited(_load()),
          child: const Text('Try again'),
        ),
      );
    }

    final blocked = _blocked;
    if (blocked == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (blocked.isEmpty) {
      return const _Centered(
        icon: Icons.block,
        title: 'You have not blocked anyone.',
        subtitle: 'Blocked accounts cannot follow you, and you will not see '
            'each other in the app.',
      );
    }

    return ListView.separated(
      itemCount: blocked.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = blocked[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                user.avatarUrl == null ? null : NetworkImage(user.avatarUrl!),
            child: user.avatarUrl == null
                ? Text(user.effectiveDisplayName.characters.first.toUpperCase())
                : null,
          ),
          title: Text(user.effectiveDisplayName),
          subtitle: user.username.isEmpty ? null : Text('@${user.username}'),
          trailing: TextButton(
            onPressed: () => unawaited(_unblock(user)),
            child: const Text('Unblock'),
          ),
        );
      },
    );
  }
}

/// Empty and error states share a shape so the screen never renders a bare
/// spinner-less void — the audit found two screens that did.
class _Centered extends StatelessWidget {
  const _Centered({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.ggTokens;

    // ListView rather than Column so RefreshIndicator still has something to
    // pull on when the list is empty.
    return ListView(
      padding: EdgeInsets.all(tokens.spaceLg),
      children: [
        SizedBox(height: tokens.spaceXl * 2),
        Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(height: tokens.spaceMd),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        if (subtitle != null) ...[
          SizedBox(height: tokens.spaceSm),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (action != null) ...[
          SizedBox(height: tokens.spaceLg),
          Center(child: action),
        ],
      ],
    );
  }
}
