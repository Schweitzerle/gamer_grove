import 'package:gamer_grove/domain/entities/user/user.dart';

/// Shared test fixtures.
///
/// Keep construction of common domain objects here so tests stay focused on
/// behaviour rather than boilerplate.
User buildTestUser({
  String id = 'user-1',
  String username = 'tester',
  String? displayName,
  int totalGamesRated = 0,
}) {
  final now = DateTime.utc(2026);
  return User(
    id: id,
    username: username,
    displayName: displayName,
    createdAt: now,
    updatedAt: now,
    totalGamesRated: totalGamesRated,
  );
}
