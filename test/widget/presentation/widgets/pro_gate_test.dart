import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/entitlements/entitlements.dart';
import 'package:gamer_grove/core/entitlements/pro_feature.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/widgets/pro/pro_gate.dart';

class _FakeEntitlementService implements EntitlementService {
  _FakeEntitlementService(this._entitlements);

  Entitlements _entitlements;
  final StreamController<Entitlements> _controller =
      StreamController<Entitlements>.broadcast();

  @override
  Entitlements get entitlements => _entitlements;

  @override
  Stream<Entitlements> get changes => _controller.stream;

  @override
  bool has(ProFeature feature) => _entitlements.has(feature);

  @override
  Future<void> refresh() async {}

  @override
  Future<void> dispose() async => _controller.close();

  void emit(Entitlements next) {
    _entitlements = next;
    _controller.add(next);
  }
}

void main() {
  late _FakeEntitlementService fake;

  void register(Entitlements initial) {
    fake = _FakeEntitlementService(initial);
    if (sl.isRegistered<EntitlementService>()) {
      sl.unregister<EntitlementService>();
    }
    sl.registerSingleton<EntitlementService>(fake);
  }

  tearDown(() {
    if (sl.isRegistered<EntitlementService>()) {
      sl.unregister<EntitlementService>();
    }
  });

  Widget gate() => const MaterialApp(
        home: ProGate(
          feature: ProFeature.extendedStats,
          builder: _content,
          lockedBuilder: _locked,
        ),
      );

  testWidgets('shows the locked builder for free users', (tester) async {
    register(const Entitlements.free());

    await tester.pumpWidget(gate());
    await tester.pump();

    expect(find.text('LOCKED'), findsOneWidget);
    expect(find.text('CONTENT'), findsNothing);
  });

  testWidgets('shows the content builder for Pro users', (tester) async {
    register(const Entitlements.pro());

    await tester.pumpWidget(gate());
    await tester.pump();

    expect(find.text('CONTENT'), findsOneWidget);
    expect(find.text('LOCKED'), findsNothing);
  });

  testWidgets('swaps locked → content live when entitlement changes',
      (tester) async {
    register(const Entitlements.free());

    await tester.pumpWidget(gate());
    await tester.pump();
    expect(find.text('LOCKED'), findsOneWidget);

    fake.emit(const Entitlements.pro());
    await tester.pump(); // deliver stream event → setState
    await tester.pump(); // render the rebuilt tree

    expect(find.text('CONTENT'), findsOneWidget);
    expect(find.text('LOCKED'), findsNothing);
  });
}

Widget _content(BuildContext context) => const Text('CONTENT');

Widget _locked(BuildContext context) => const Text('LOCKED');
