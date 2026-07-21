import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/analytics/analytics_events.dart';
import 'package:gamer_grove/core/analytics/analytics_service.dart';
import 'package:gamer_grove/core/entitlements/pro_plan.dart';
import 'package:gamer_grove/presentation/pages/paywall/paywall_page.dart';
import 'package:gamer_grove/presentation/pages/paywall/widgets/pro_plan_card.dart';

/// Records tracked event names + properties for asserting the funnel wiring.
class _RecordingAnalytics implements AnalyticsService {
  final List<(String, Map<String, Object?>?)> events = [];

  List<String> get names => events.map((e) => e.$1).toList();

  @override
  Future<void> track(String name, {Map<String, Object?>? properties}) async {
    events.add((name, properties));
  }

  @override
  Future<void> screen(String screenName) async {}
}

void main() {
  late _RecordingAnalytics analytics;

  setUp(() => analytics = _RecordingAnalytics());

  Future<void> pumpPaywall(
    WidgetTester tester, {
    String source = 'settings',
    PurchaseHandler? onPurchase,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PaywallPage(
          analytics: analytics,
          source: source,
          onPurchase: onPurchase,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the Pro hero, feature list and both plans',
      (tester) async {
    await pumpPaywall(tester);

    expect(find.text('GamerGrove Pro'), findsOneWidget);
    expect(find.text('Deep stats & insights'), findsOneWidget);
    expect(find.byType(ProPlanCard), findsNWidgets(ProPlans.all.length));
    expect(find.text('19,99 €'), findsOneWidget);
    expect(find.text('2,99 €'), findsOneWidget);
  });

  testWidgets('tracks paywall_view with the source on open', (tester) async {
    await pumpPaywall(tester, source: 'game_detail');

    expect(analytics.names, contains(AnalyticsEvents.paywallView));
    final event =
        analytics.events.firstWhere((e) => e.$1 == AnalyticsEvents.paywallView);
    expect(event.$2?[AnalyticsProps.source], 'game_detail');
  });

  testWidgets('yearly plan is selected by default', (tester) async {
    await pumpPaywall(tester);

    final yearly = tester.widget<ProPlanCard>(
      find.byWidgetPredicate(
        (w) => w is ProPlanCard && w.plan == ProPlans.yearly,
      ),
    );
    final monthly = tester.widget<ProPlanCard>(
      find.byWidgetPredicate(
        (w) => w is ProPlanCard && w.plan == ProPlans.monthly,
      ),
    );
    expect(yearly.selected, isTrue);
    expect(monthly.selected, isFalse);
  });

  testWidgets('selecting the monthly plan updates the selection',
      (tester) async {
    await pumpPaywall(tester);

    await tester.ensureVisible(find.text('2,99 €'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2,99 €'));
    await tester.pump();

    final monthly = tester.widget<ProPlanCard>(
      find.byWidgetPredicate(
        (w) => w is ProPlanCard && w.plan == ProPlans.monthly,
      ),
    );
    expect(monthly.selected, isTrue);
  });

  testWidgets(
      'CTA tracks purchase_start with the selected plan and does not complete '
      'a purchase when billing is not configured', (tester) async {
    await pumpPaywall(tester);

    await tester.tap(find.text('Start GamerGrove Pro'));
    await tester.pump();

    final event = analytics.events
        .firstWhere((e) => e.$1 == AnalyticsEvents.purchaseStart);
    expect(event.$2?[AnalyticsProps.plan], ProPlans.yearly.id);
    expect(analytics.names, isNot(contains(AnalyticsEvents.purchaseDone)));

    // Let the "coming soon" toast timer flush so no timer is left pending.
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('successful purchase tracks purchase_done and pops with true',
      (tester) async {
    var popped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => PaywallPage(
                        analytics: analytics,
                        onPurchase: (_) async => true,
                      ),
                    ),
                  );
                  popped = result ?? false;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start GamerGrove Pro'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6)); // flush success toast timer
    await tester.pumpAndSettle();

    expect(analytics.names, contains(AnalyticsEvents.purchaseDone));
    expect(popped, isTrue);
  });

  testWidgets('meets tap-target and labelled-target guidelines',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPaywall(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });
}
