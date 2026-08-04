import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/pages/settings/blocked_users_page.dart';

/// Serves a fixed block list and records unblocks.
///
/// Deliberately implements only what the page touches — `noSuchMethod` makes
/// any other call throw, so a future change that starts using a different
/// repository method fails loudly instead of quietly getting null.
class _FakeUserRepo implements UserRepository {
  _FakeUserRepo(
    this._blocked, {
    this.failLoad = false,
    this.failUnblock = false,
  });

  final List<User> _blocked;
  final bool failLoad;
  final bool failUnblock;
  final unblocked = <String>[];

  @override
  Future<Either<Failure, List<User>>> getBlockedUsers({
    required String userId,
  }) async =>
      failLoad ? const Left(ServerFailure(message: 'nope')) : Right(_blocked);

  @override
  Future<Either<Failure, void>> unblockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (failUnblock) return const Left(ServerFailure(message: 'nope'));
    unblocked.add(targetUserId);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

User _user(String id, String name) => User(
      id: id,
      username: name.toLowerCase(),
      displayName: name,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  late _FakeUserRepo repo;

  // Awaited rather than fire-and-forget: get_it's unregister returns a
  // FutureOr, and a registration that lands after the next test starts is a
  // flake that only shows up under load.
  Future<void> register(_FakeUserRepo fake) async {
    repo = fake;
    if (sl.isRegistered<UserRepository>()) {
      await sl.unregister<UserRepository>();
    }
    sl.registerSingleton<UserRepository>(fake);
  }

  tearDown(() async {
    if (sl.isRegistered<UserRepository>()) {
      await sl.unregister<UserRepository>();
    }
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: GGTheme.dark(),
        home: const BlockedUsersPage(currentUserId: 'me'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists the blocked accounts', (tester) async {
    await register(_FakeUserRepo([_user('a', 'Alice'), _user('b', 'Bob')]));
    await pump(tester);

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Unblock'), findsNWidgets(2));
  });

  testWidgets('teaches rather than showing a bare void when empty',
      (tester) async {
    await register(_FakeUserRepo([]));
    await pump(tester);

    expect(find.text('You have not blocked anyone.'), findsOneWidget);
    // An empty state that only says "empty" is the defect; this one explains
    // what blocking would do.
    expect(find.textContaining('cannot follow you'), findsOneWidget);
  });

  testWidgets('unblocking removes the row and reports it once', (tester) async {
    await register(_FakeUserRepo([_user('a', 'Alice'), _user('b', 'Bob')]));
    await pump(tester);

    await tester.tap(find.text('Unblock').first);
    await tester.pumpAndSettle();

    expect(repo.unblocked, ['a']);
    expect(find.text('Alice'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Alice is unblocked.'), findsOneWidget);
  });

  testWidgets('a failed unblock leaves the row alone', (tester) async {
    await register(_FakeUserRepo([_user('a', 'Alice')], failUnblock: true));
    await pump(tester);

    await tester.tap(find.text('Unblock'));
    await tester.pumpAndSettle();

    // The row must not disappear optimistically — it would look unblocked
    // while the block is still in force.
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Could not unblock Alice.'), findsOneWidget);
  });

  testWidgets('a failed load offers a way out', (tester) async {
    await register(_FakeUserRepo([], failLoad: true));
    await pump(tester);

    expect(find.text('Could not load your blocked accounts.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await register(_FakeUserRepo([_user('a', 'Alice')]));
    await pump(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });

  testWidgets('survives 200% text scale', (tester) async {
    await register(_FakeUserRepo([_user('a', 'Alice')]));
    await tester.pumpWidget(
      MaterialApp(
        theme: GGTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const BlockedUsersPage(currentUserId: 'me'),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
