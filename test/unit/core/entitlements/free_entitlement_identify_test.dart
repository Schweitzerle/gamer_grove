import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';

void main() {
  // The RevenueCat implementation needs a configured native SDK, so it is
  // verified by a real sandbox purchase. What is worth locking down here is
  // that identify() exists on the interface and that the free tier tolerates
  // it — the auth listener calls it unconditionally on every sign-in.
  test('the free service accepts identify without changing entitlements',
      () async {
    final service = FreeEntitlementService();
    addTearDown(service.dispose);

    await service.identify('user-1');
    expect(service.entitlements.isPro, isFalse);

    await service.identify(null);
    expect(service.entitlements.isPro, isFalse);
  });
}
