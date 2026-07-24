import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/presentation/pages/profile/widgets/delete_account_dialog.dart';

void main() {
  /// Opens the dialog and records what it returned.
  Future<List<bool>> open(WidgetTester tester) async {
    final results = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async => results.add(
                  await confirmAccountDeletion(context, username: 'tester'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('spells out what deletion removes', (tester) async {
    await open(tester);

    expect(find.text('Delete account?'), findsOneWidget);
    expect(
      find.textContaining('cannot be undone'),
      findsOneWidget,
    );
    // Store billing is outside our reach — the user must be told.
    expect(
      find.textContaining('Cancel it in the Google Play Store first.'),
      findsOneWidget,
    );
  });

  testWidgets('keeps the destructive action locked until the username matches',
      (tester) async {
    await open(tester);

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Delete permanently'),
    );
    expect(button.onPressed, isNull, reason: 'locked before typing');

    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Delete permanently'),
          )
          .onPressed,
      isNull,
      reason: 'still locked for a wrong name',
    );

    await tester.enterText(find.byType(TextField), 'tester');
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Delete permanently'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('returns true only after confirming', (tester) async {
    final results = await open(tester);

    await tester.enterText(find.byType(TextField), 'tester');
    await tester.pump();
    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();

    expect(results, [true]);
  });

  testWidgets('returns false when cancelled', (tester) async {
    final results = await open(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(results, [false]);
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}
