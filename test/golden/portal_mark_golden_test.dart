import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/widgets/gg_portal_mark.dart';

import '../support/load_app_fonts.dart';

/// The mark, at the three sizes the app draws it and in both themes.
///
/// It replaces a d-pad that had survived the rebrand on the sign-in screen, in
/// the app bar and on the Grove's tab — the exact motif the icon was rebuilt to
/// avoid, on the first screen anyone sees. A golden is the cheapest way to
/// notice if it ever comes back.
void main() {
  setUpAll(loadAppFonts);

  for (final (name, theme) in [
    ('dark', GGTheme.dark()),
    ('light', GGTheme.light()),
  ]) {
    testWidgets('the portal mark — $name', (tester) async {
      tester.view.physicalSize = const Size(360, 160);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bottom bar, unselected and selected, then the app bar.
                  GGPortalMark(),
                  GGPortalMark(lit: 0.62),
                  GGPortalMark(size: 22),
                  GGPortalMark(size: 44, lit: 0.55),
                  GGPortalMark(size: 80, lit: 0.55),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/portal_mark_$name.png'),
      );
    });
  }
}
