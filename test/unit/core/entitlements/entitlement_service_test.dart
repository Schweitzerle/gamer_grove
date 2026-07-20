import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/entitlements/entitlements.dart';
import 'package:gamer_grove/core/entitlements/pro_feature.dart';

void main() {
  group('Entitlements', () {
    test('free tier is not pro and gates every Pro feature', () {
      const free = Entitlements.free();

      expect(free.isPro, isFalse);
      expect(free.isFree, isTrue);
      for (final feature in ProFeature.values) {
        expect(free.has(feature), isFalse, reason: feature.name);
      }
    });

    test('pro tier unlocks every Pro feature', () {
      const pro = Entitlements.pro();

      expect(pro.isPro, isTrue);
      expect(pro.isFree, isFalse);
      for (final feature in ProFeature.values) {
        expect(pro.has(feature), isTrue, reason: feature.name);
      }
    });

    test('value equality by isPro', () {
      expect(const Entitlements.free(), const Entitlements(isPro: false));
      expect(const Entitlements.pro(), const Entitlements(isPro: true));
      expect(const Entitlements.free(), isNot(const Entitlements.pro()));
    });
  });

  group('FreeEntitlementService', () {
    late FreeEntitlementService service;

    setUp(() => service = FreeEntitlementService());
    tearDown(() => service.dispose());

    test('reports the free entitlement and closes every Pro gate', () {
      expect(service.entitlements, const Entitlements.free());
      for (final feature in ProFeature.values) {
        expect(service.has(feature), isFalse, reason: feature.name);
      }
    });

    test('changes stream emits the free entitlement', () {
      expect(service.changes, emits(const Entitlements.free()));
    });

    test('refresh is a safe no-op', () async {
      await expectLater(service.refresh(), completes);
      expect(service.entitlements, const Entitlements.free());
    });
  });
}
