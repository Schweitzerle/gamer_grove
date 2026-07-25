import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/entitlements/entitlements.dart';
import 'package:gamer_grove/core/entitlements/pro_feature.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/pages/collections/collection_create_gate.dart';

class _FakeEntitlementService implements EntitlementService {
  _FakeEntitlementService(this._entitlements);

  final Entitlements _entitlements;
  final StreamController<Entitlements> _controller =
      StreamController<Entitlements>.broadcast();
  int refreshCalls = 0;

  @override
  Entitlements get entitlements => _entitlements;

  @override
  Stream<Entitlements> get changes => _controller.stream;

  @override
  bool has(ProFeature feature) => _entitlements.has(feature);

  @override
  Future<void> refresh() async => refreshCalls++;

  @override
  Future<void> identify(String? userId) async {}

  @override
  Future<void> dispose() async => _controller.close();
}

void main() {
  group('decideServerLimitOutcome', () {
    // The regression this guards: a user the client already considered Pro fell
    // into the paywall branch, where requirePro returned instantly without any
    // UI — tapping Create appeared to do nothing at all.
    test('a Pro user is told about the mismatch, never shown the paywall', () {
      expect(
        decideServerLimitOutcome(isPro: true),
        ServerLimitOutcome.mismatchReported,
      );
    });

    test('a free user is offered the upgrade', () {
      expect(
        decideServerLimitOutcome(isPro: false),
        ServerLimitOutcome.upgradeOffered,
      );
    });
  });

  group('handleServerCollectionLimit', () {
    late _FakeEntitlementService fake;

    Future<void> register(Entitlements initial) async {
      fake = _FakeEntitlementService(initial);
      if (sl.isRegistered<EntitlementService>()) {
        await sl.unregister<EntitlementService>();
      }
      sl.registerSingleton<EntitlementService>(fake);
      // The paywall route pulls an analytics service from the locator.
      if (!sl.isRegistered<AnalyticsService>()) {
        sl.registerSingleton<AnalyticsService>(const NoopAnalyticsService());
      }
    }

    tearDown(() async {
      if (sl.isRegistered<EntitlementService>()) {
        await sl.unregister<EntitlementService>();
      }
      if (sl.isRegistered<AnalyticsService>()) {
        await sl.unregister<AnalyticsService>();
      }
    });

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => handleServerCollectionLimit(context),
                  child: const Text('reject'),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('a free user actually lands on the paywall', (tester) async {
      await register(const Entitlements.free());
      await pump(tester);

      await tester.tap(find.text('reject'));
      await tester.pumpAndSettle();

      expect(find.text('GamerGrove Pro'), findsWidgets);
      expect(fake.refreshCalls, 0, reason: 'no mismatch to re-check');
    });

    // The Pro branch is covered by decideServerLimitOutcome above: its toast
    // comes from toasty_box, which leaves a timer outliving the widget tree and
    // therefore cannot be asserted in a widget test.
  });
}
