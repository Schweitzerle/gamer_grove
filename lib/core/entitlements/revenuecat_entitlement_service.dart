import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/core/entitlements/entitlements.dart';
import 'package:gamer_grove/core/entitlements/pro_feature.dart';
import 'package:gamer_grove/core/entitlements/pro_plan.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// [EntitlementService] backed by RevenueCat.
///
/// Only used when `REVENUECAT_API_KEY` is configured; otherwise the app falls
/// back to [FreeEntitlementService]. The RevenueCat SDK exposes a static API,
/// so this class is verified via a real sandbox purchase rather than unit tests
/// (the free path and the interface are unit-tested separately).
class RevenueCatEntitlementService implements EntitlementService {
  RevenueCatEntitlementService._();

  /// Entitlement identifier configured in the RevenueCat dashboard.
  static const String proEntitlementId = 'pro';

  /// Offering identifier configured in the RevenueCat dashboard.
  static const String offeringId = 'default';

  final StreamController<Entitlements> _controller =
      StreamController<Entitlements>.broadcast();
  Entitlements _current = const Entitlements.free();

  /// Configures the RevenueCat SDK and returns a ready service.
  ///
  /// [appUserId] links purchases to the signed-in user (RevenueCat manages an
  /// anonymous id when null).
  static Future<RevenueCatEntitlementService> configure({
    required String apiKey,
    String? appUserId,
  }) async {
    await Purchases.configure(
      PurchasesConfiguration(apiKey)..appUserID = appUserId,
    );
    final service = RevenueCatEntitlementService._();
    Purchases.addCustomerInfoUpdateListener(service._onCustomerInfo);
    await service.refresh();
    return service;
  }

  void _onCustomerInfo(CustomerInfo info) {
    final next = Entitlements(
      isPro: info.entitlements.active.containsKey(proEntitlementId),
    );
    if (next != _current) {
      _current = next;
      _controller.add(next);
    }
  }

  @override
  Entitlements get entitlements => _current;

  @override
  Stream<Entitlements> get changes => _controller.stream;

  @override
  bool has(ProFeature feature) => _current.has(feature);

  @override
  Future<void> refresh() async {
    try {
      _onCustomerInfo(await Purchases.getCustomerInfo());
    } on PlatformException {
      // Keep the last known entitlement on transient errors.
    }
  }

  /// Attempts to purchase [plan]. Returns true when Pro is active afterwards.
  /// A user cancellation returns false without surfacing an error.
  Future<bool> purchase(ProPlan plan) async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering(offeringId) ?? offerings.current;
      final package = _packageFor(offering, plan);
      if (package == null) return false;
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _onCustomerInfo(result.customerInfo);
      return _current.isPro;
    } on PlatformException catch (e) {
      // Cancellation is a normal outcome, not an error to report.
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) return false;
      return false;
    }
  }

  /// Restores previous purchases. Returns true when Pro is active afterwards.
  Future<bool> restore() async {
    try {
      _onCustomerInfo(await Purchases.restorePurchases());
      return _current.isPro;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfo);
    await _controller.close();
  }

  Package? _packageFor(Offering? offering, ProPlan plan) {
    if (offering == null) return null;
    final byPeriod = plan.period == ProBillingPeriod.yearly
        ? offering.annual
        : offering.monthly;
    if (byPeriod != null) return byPeriod;
    // Fallback: match by the underlying store product id.
    for (final package in offering.availablePackages) {
      if (package.storeProduct.identifier == plan.id) return package;
    }
    return null;
  }
}
