import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/entitlements/entitlement_service.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/user_collections/user_collections_bloc.dart';
import 'package:gamer_grove/presentation/pages/grove/widgets/collections_section.dart';

class _MockBloc extends MockBloc<UserCollectionsEvent, UserCollectionsState>
    implements UserCollectionsBloc {}

void main() {
  late _MockBloc bloc;

  setUp(() async {
    bloc = _MockBloc();
    // The empty-state create action gates on entitlements via the locator.
    if (sl.isRegistered<EntitlementService>()) {
      await sl.unregister<EntitlementService>();
    }
    sl.registerSingleton<EntitlementService>(FreeEntitlementService());
  });

  tearDown(() async {
    await bloc.close();
    if (sl.isRegistered<EntitlementService>()) {
      await sl.unregister<EntitlementService>();
    }
  });

  Future<void> pump(WidgetTester tester, UserCollectionsState state) async {
    whenListen(
      bloc,
      const Stream<UserCollectionsState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<UserCollectionsBloc>.value(
            value: bloc,
            child: const CollectionsSection(userId: 'u1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  UserCollection col(String id, String name, {int count = 0}) =>
      UserCollection(id: id, userId: 'u1', name: name, gameCount: count);

  testWidgets('renders a card per collection with its game count',
      (tester) async {
    await pump(
      tester,
      UserCollectionsLoaded(
        userId: 'u1',
        collections: [col('c1', 'Cozy games', count: 3), col('c2', 'Backlog')],
      ),
    );

    expect(find.text('My Collections'), findsOneWidget);
    expect(find.text('Cozy games'), findsOneWidget);
    expect(find.text('Backlog'), findsOneWidget);
    expect(find.text('3 games'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
  });

  testWidgets('offers creating one instead of "View All" when empty',
      (tester) async {
    await pump(
      tester,
      const UserCollectionsLoaded(userId: 'u1', collections: []),
    );

    expect(find.text('Create collection'), findsOneWidget);
    expect(find.text('View All'), findsNothing);
  });

  testWidgets('surfaces a load error in place of the strip', (tester) async {
    await pump(tester, const UserCollectionsError('offline'));

    expect(find.text('offline'), findsOneWidget);
    expect(find.text('View All'), findsNothing);
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      UserCollectionsLoaded(
        userId: 'u1',
        collections: [col('c1', 'Cozy games', count: 1)],
      ),
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}
