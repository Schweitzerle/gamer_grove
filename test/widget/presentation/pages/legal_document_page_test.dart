import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/presentation/pages/legal/legal_document_page.dart';

/// Reads the document from disk. The widget tests cover that it is also
/// bundled as an asset; these checks are about the text itself.
String _read(LegalDocument doc) => File(doc.assetPath).readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(WidgetTester tester, LegalDocument doc) async {
    await tester.pumpWidget(
      MaterialApp(home: LegalDocumentPage(document: doc)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the English privacy policy from the bundled asset',
      (tester) async {
    await pump(tester, LegalDocument.privacyPolicy);

    expect(find.text('Privacy Policy'), findsWidgets); // app bar + heading
    expect(find.text('1. Controller'), findsOneWidget);
    // Markdown syntax must not leak into the rendered text.
    expect(find.textContaining('##'), findsNothing);
    expect(find.textContaining('- '), findsNothing);
  });

  testWidgets('renders the German documents', (tester) async {
    await pump(tester, LegalDocument.datenschutz);
    expect(find.text('1. Verantwortlicher'), findsOneWidget);

    await pump(tester, LegalDocument.impressum);
    expect(find.text('Diensteanbieter'), findsOneWidget);
  });

  group('document content', () {
    /// Every processor that receives data must be named — omitting one is the
    /// classic way a privacy policy becomes wrong.
    const processors = [
      'Supabase',
      'IGDB',
      'Sentry',
      'Umami',
      'RevenueCat',
      'Google Play Billing',
    ];

    test('the English policy names every processor', () {
      final text = _read(LegalDocument.privacyPolicy);

      for (final name in processors) {
        expect(text, contains(name), reason: '$name is not disclosed');
      }
    });

    test('the German policy names every processor', () {
      final text = _read(LegalDocument.datenschutz);

      for (final name in processors) {
        expect(text, contains(name), reason: '$name is not disclosed');
      }
    });

    test('both policies explain account deletion and the subscription caveat',
        () {
      for (final doc in [
        LegalDocument.privacyPolicy,
        LegalDocument.datenschutz,
      ]) {
        final text = _read(doc);
        expect(text, contains('Delete account'));
        // Deleting the account does not stop Play billing — users must be told.
        expect(text.toLowerCase(), contains('play store'));
      }
    });
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    // Explicit pumps rather than pumpAndSettle: the loading spinner animates
    // continuously, which pumpAndSettle cannot settle on.
    await tester.pumpWidget(
      const MaterialApp(
        home: LegalDocumentPage(document: LegalDocument.privacyPolicy),
      ),
    );
    await tester.pump();
    await tester.pump();

    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}
