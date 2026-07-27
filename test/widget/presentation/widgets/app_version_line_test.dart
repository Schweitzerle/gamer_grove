import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/presentation/widgets/app_version_line.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The point of this line is that a tester can read out which build they are
/// holding. That only works if it comes from the installed package — the
/// hardcoded string it replaces said "v2.0.0" while the app was on 2.0.2.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'GamerGrove',
      packageName: 'com.schweizerle.gamergrove',
      version: '2.0.2',
      buildNumber: '20',
      buildSignature: '',
    );
  });

  testWidgets('shows the version and the build it was installed from',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppVersionLine())),
    );
    await tester.pumpAndSettle();

    expect(find.text('GamerGrove v2.0.2 (Build 20)'), findsOneWidget);
  });

  testWidgets('a screen reader gets it as one announcement', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppVersionLine())),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('App version: GamerGrove v2.0.2 (Build 20)'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
