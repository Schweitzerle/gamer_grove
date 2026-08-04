import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/pages/user_detail/widgets/user_moderation_menu.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: GGTheme.dark(), home: Scaffold(body: child));

  group('UserModerationMenu', () {
    Future<List<ModerationAction>> openMenu(WidgetTester tester) async {
      final picked = <ModerationAction>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: GGTheme.dark(),
          home: Scaffold(
            appBar: AppBar(
              actions: [UserModerationMenu(onSelected: picked.add)],
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      return picked;
    }

    testWidgets('offers reporting and blocking', (tester) async {
      await openMenu(tester);

      expect(find.text('Report user'), findsOneWidget);
      expect(find.text('Block user'), findsOneWidget);
    });

    testWidgets('reports which action was chosen', (tester) async {
      final picked = await openMenu(tester);

      await tester.tap(find.text('Report user'));
      await tester.pumpAndSettle();

      expect(picked, [ModerationAction.report]);
    });

    testWidgets('the trigger carries a label for screen readers',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: GGTheme.dark(),
          home: Scaffold(
            appBar: AppBar(
              actions: [UserModerationMenu(onSelected: (_) {})],
            ),
          ),
        ),
      );

      // An IconButton without this announces "button" and nothing else, which
      // is the single most common a11y defect in this codebase.
      expect(
        tester
            .widget<PopupMenuButton<ModerationAction>>(
              find.byType(PopupMenuButton<ModerationAction>),
            )
            .tooltip,
        'More options',
      );
    });
  });

  group('report sheet', () {
    /// Opens the sheet and hands back the pending result.
    ///
    /// The future is captured rather than folded into a list by an async
    /// callback: `pumpAndSettle` drives frames, not the continuation after
    /// `await`, so awaiting it explicitly is what makes the assertion
    /// deterministic instead of timing-dependent.
    Future<Future<ReportResult?>> open(WidgetTester tester) async {
      late Future<ReportResult?> pending;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () =>
                    pending = showReportSheet(context, displayName: 'PlayTest'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return pending;
    }

    testWidgets('names the person and promises no disclosure', (tester) async {
      unawaited(await open(tester));

      expect(find.text('Report PlayTest'), findsOneWidget);
      expect(
        find.textContaining('not shared with them'),
        findsOneWidget,
      );
    });

    testWidgets('offers exactly the reasons the database accepts',
        (tester) async {
      unawaited(await open(tester));

      // The CHECK constraint rejects anything else, so a mismatch here would
      // surface as a failed insert rather than a validation message.
      for (final reason in ReportReason.values) {
        expect(find.text(reason.label), findsOneWidget);
      }
      expect(
        ReportReason.values.map((r) => r.wireValue).toSet(),
        {
          'spam',
          'harassment',
          'inappropriate_content',
          'fake_account',
          'other',
        },
      );
    });

    testWidgets('keeps sending locked until a reason is picked',
        (tester) async {
      unawaited(await open(tester));

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.text('Harassment or bullying'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('returns the wire value and the optional detail',
        (tester) async {
      final pending = await open(tester);

      await tester.tap(find.text('Spam'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  bot account  ');
      await tester.ensureVisible(find.text('Send report'));
      await tester.tap(find.text('Send report'));
      await tester.pumpAndSettle();

      final result = await pending;
      expect(result!.reason.wireValue, 'spam');
      // Trimmed, so a field of spaces does not become a "description".
      expect(result.description, 'bot account');
    });

    testWidgets('sends no description when the field is left blank',
        (tester) async {
      final pending = await open(tester);

      await tester.tap(find.text('Spam'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Send report'));
      await tester.tap(find.text('Send report'));
      await tester.pumpAndSettle();

      expect((await pending)!.description, isNull);
    });

    testWidgets('meets accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      unawaited(await open(tester));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });
  });

  group('block confirmation', () {
    Future<List<bool>> open(WidgetTester tester) async {
      final results = <bool>[];
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async => results.add(
                  await confirmBlock(context, displayName: 'PlayTest'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('says what blocking does instead of asking "are you sure"',
        (tester) async {
      await open(tester);

      expect(find.text('Block PlayTest?'), findsOneWidget);
      expect(find.textContaining('stop following each other'), findsOneWidget);
      // The blocked user is never told — that is a promise the UI makes and
      // the RLS policy keeps.
      expect(find.textContaining('is not told about this'), findsOneWidget);
    });

    testWidgets('dismissing is not blocking', (tester) async {
      final results = await open(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(results, [false]);
    });

    testWidgets('confirming returns true', (tester) async {
      final results = await open(tester);

      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();

      expect(results, [true]);
    });

    testWidgets('meets accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await open(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('survives 200% text scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: GGTheme.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async =>
                      confirmBlock(context, displayName: 'PlayTest'),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
