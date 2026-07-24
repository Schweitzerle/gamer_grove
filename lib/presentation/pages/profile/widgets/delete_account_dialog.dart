import 'package:flutter/material.dart';

/// Confirmation for permanent account deletion.
///
/// Deleting is irreversible, so this asks the user to type their username
/// before the destructive action unlocks — a single tap is too easy to hit by
/// accident for something that cannot be undone.
///
/// Returns `true` only when the user confirmed.
Future<bool> confirmAccountDeletion(
  BuildContext context, {
  required String username,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _DeleteAccountDialog(username: username),
  );
  return confirmed ?? false;
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.username});

  final String username;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _matches = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final matches = _controller.text.trim() == widget.username;
      if (matches != _matches) setState(() => _matches = matches);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Delete account?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This permanently deletes your profile, collections, ratings, '
              'wishlist and follows. It cannot be undone.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            // Store subscriptions live with Google, not with us — deleting the
            // account here would otherwise keep billing the user.
            Text(
              'An active GamerGrove Pro subscription is not cancelled by this. '
              'Cancel it in the Google Play Store first.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Type ${widget.username} to confirm:',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                labelText: 'Username',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: const Text('Delete permanently'),
        ),
      ],
    );
  }
}
