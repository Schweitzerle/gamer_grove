import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';

/// Reasons a user can be reported for.
///
/// These are the five values `user_reports.valid_reason` accepts. The wire
/// value is what goes into the column; anything else is rejected by the CHECK
/// constraint rather than stored, so the two lists have to stay in step.
enum ReportReason {
  spam('spam', 'Spam'),
  harassment('harassment', 'Harassment or bullying'),
  inappropriateContent('inappropriate_content', 'Inappropriate content'),
  fakeAccount('fake_account', 'Fake account'),
  other('other', 'Something else');

  const ReportReason(this.wireValue, this.label);

  final String wireValue;
  final String label;
}

/// What the moderation sheet was asked to do.
enum ModerationAction { report, block }

/// The result of reporting: a reason, and optionally the user's own words.
class ReportResult {
  const ReportResult({required this.reason, this.description});

  final ReportReason reason;
  final String? description;
}

/// Overflow entry point for reporting and blocking another user.
///
/// Sits in the app bar rather than in the page body: these are rare, negative
/// actions, and giving them a permanent slot next to "Follow" would weight them
/// far above their frequency. It is a visible, discoverable control rather than
/// a long-press, because a hidden gesture has no accessible equivalent
/// (WCAG 2.5.7) and a Play reviewer will not find it.
///
/// Belongs on private profiles too — being unable to see someone's shelf is no
/// reason to be unable to report them.
class UserModerationMenu extends StatelessWidget {
  const UserModerationMenu({
    required this.onSelected,
    super.key,
  });

  final ValueChanged<ModerationAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ModerationAction>(
      // Without this the screen reader announces "button" and nothing else.
      tooltip: 'More options',
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: ModerationAction.report,
          child: ListTile(
            leading: Icon(Icons.flag_outlined),
            title: Text('Report user'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: ModerationAction.block,
          child: ListTile(
            leading: Icon(Icons.block),
            title: Text('Block user'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

/// Asks for a reason and optional detail. Returns null if dismissed.
Future<ReportResult?> showReportSheet(
  BuildContext context, {
  required String displayName,
}) {
  return showModalBottomSheet<ReportResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ReportSheet(displayName: displayName),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.displayName});

  final String displayName;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason? _reason;
  late final TextEditingController _detail = TextEditingController();

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.ggTokens;

    return Padding(
      padding: EdgeInsets.only(
        left: tokens.spaceLg,
        right: tokens.spaceLg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + tokens.spaceLg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Report ${widget.displayName}',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              'Tell us what is wrong. Your report is not shared with them.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: tokens.spaceMd),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (value) => setState(() => _reason = value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final reason in ReportReason.values)
                    RadioListTile<ReportReason>(
                      value: reason,
                      title: Text(reason.label),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            TextField(
              controller: _detail,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Anything else? (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            FilledButton(
              onPressed: _reason == null
                  ? null
                  : () => Navigator.of(context).pop(
                        ReportResult(
                          reason: _reason!,
                          description: _detail.text.trim().isEmpty
                              ? null
                              : _detail.text.trim(),
                        ),
                      ),
              child: const Text('Send report'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirms a block. Returns true if the user went through with it.
///
/// Blocking is one of the few places a confirmation earns its keep: it is
/// destructive of a relationship (both follow directions are dissolved) and
/// the consequence is not obvious from the button alone, so the dialog says
/// what will happen rather than asking "are you sure?".
Future<bool> confirmBlock(
  BuildContext context, {
  required String displayName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Block $displayName?'),
      content: Text(
        'They will no longer be able to follow you, and you will stop '
        'following each other. $displayName is not told about this.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Block'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
