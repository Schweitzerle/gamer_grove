// lib/domain/entities/user/user_top_three.dart
import 'package:equatable/equatable.dart';

class UserTopThree extends Equatable {
  final int? firstGameId;
  final int? secondGameId;
  final int? thirdGameId;

  const UserTopThree({
    this.firstGameId,
    this.secondGameId,
    this.thirdGameId,
  });

  const UserTopThree.empty() : this();

  // Helper getters
  bool get isComplete => firstGameId != null && secondGameId != null && thirdGameId != null;
  bool get hasFirst => firstGameId != null;
  bool get hasSecond => secondGameId != null;
  bool get hasThird => thirdGameId != null;
  int get gameCount => [firstGameId, secondGameId, thirdGameId].where((id) => id != null).length;

  List<int> get gameIds => [firstGameId, secondGameId, thirdGameId]
      .where((id) => id != null)
      .cast<int>()
      .toList();

  // Get game at specific position (1-based)
  int? getGameAtPosition(int position) {
    switch (position) {
      case 1: return firstGameId;
      case 2: return secondGameId;
      case 3: return thirdGameId;
      default: return null;
    }
  }

  // Create with specific games
  UserTopThree copyWith({
    int? firstGameId,
    int? secondGameId,
    int? thirdGameId,
  }) {
    return UserTopThree(
      firstGameId: firstGameId ?? this.firstGameId,
      secondGameId: secondGameId ?? this.secondGameId,
      thirdGameId: thirdGameId ?? this.thirdGameId,
    );
  }

  // Factory methods
  factory UserTopThree.fromList(List<int> gameIds) {
    return UserTopThree(
      firstGameId: gameIds.length > 0 ? gameIds[0] : null,
      secondGameId: gameIds.length > 1 ? gameIds[1] : null,
      thirdGameId: gameIds.length > 2 ? gameIds[2] : null,
    );
  }

  factory UserTopThree.fromMap(Map<int, int> positionToGameId) {
    return UserTopThree(
      firstGameId: positionToGameId[1],
      secondGameId: positionToGameId[2],
      thirdGameId: positionToGameId[3],
    );
  }

  @override
  List<Object?> get props => [firstGameId, secondGameId, thirdGameId];
}

