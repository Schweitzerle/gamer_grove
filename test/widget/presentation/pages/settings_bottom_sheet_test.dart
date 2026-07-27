import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/entitlements/entitlements.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_state.dart';
import 'package:gamer_grove/presentation/pages/settings/settings_bottom_sheet.dart';
import 'package:gamer_grove/presentation/widgets/app_version_line.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _MockThemeBloc extends MockBloc<ThemeEvent, ThemeState>
    implements ThemeBloc {}

class _FreeEntitlements implements EntitlementService {
  @override
  Entitlements get entitlements => const Entitlements.free();

  @override
  Stream<Entitlements> get changes => const Stream<Entitlements>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// The settings sheet is where a tester reads off which build they are holding,
/// so the thing that has to be true is simply: you can get to it.
void main() {
  late _MockThemeBloc themeBloc;

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'GamerGrove',
      packageName: 'com.schweizerle.gamergrove',
      version: '2.0.2',
      buildNumber: '21',
      buildSignature: '',
    );

    themeBloc = _MockThemeBloc();
    whenListen(
      themeBloc,
      const Stream<ThemeState>.empty(),
      initialState: ThemeState.initial(),
    );

    if (sl.isRegistered<EntitlementService>()) {
      sl.unregister<EntitlementService>();
    }
    sl.registerSingleton<EntitlementService>(_FreeEntitlements());
  });

  tearDown(() {
    sl.unregister<EntitlementService>();
  });

  /// The sheet as the profile page actually opens it, on a phone.
  Future<void> openSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<ThemeBloc>.value(
        value: themeBloc,
        // Above the MaterialApp, because the sheet is built by the navigator
        // and would otherwise sit outside the provider — which is also how the
        // app itself has to be wired for this screen to work at all.
        child: MaterialApp(
          theme: GGTheme.dark(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => unawaited(
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const SettingsBottomSheet(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the build number can actually be reached', (tester) async {
    // This is the regression: the sheet had no scroll view and a Spacer, and
    // `showModalBottomSheet` caps a non-scroll-controlled sheet at 9/16 of the
    // screen. The content is taller than that, so the last ~130dp — the IGDB
    // notice and the version line — sat below the edge with no way to get
    // there. The line saying "v2.0.0" had been invisible for three releases,
    // which is part of why nobody noticed it was wrong.
    await openSheet(tester);

    expect(find.byType(AppVersionLine), findsOneWidget);

    await tester.scrollUntilVisible(find.byType(AppVersionLine), 120);
    await tester.pumpAndSettle();

    expect(find.text('GamerGrove v2.0.2 (Build 21)'), findsOneWidget);

    // Reached means on screen, not merely present in the tree.
    final line = tester.getRect(find.byType(AppVersionLine));
    final screen = tester.getRect(find.byType(MaterialApp));
    expect(line.bottom, lessThanOrEqualTo(screen.bottom));
    expect(line.top, greaterThanOrEqualTo(screen.top));
  });

  testWidgets('nothing in the sheet overflows its box', (tester) async {
    await openSheet(tester);
    expect(tester.takeException(), isNull);
  });
}
