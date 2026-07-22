import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';

/// A user-created, named collection of games (e.g. "Cozy games",
/// "Backlog 2026").
///
/// This is a first-class user feature and is intentionally separate from the
/// fixed system lists (wishlist / rated / recommended / top three). Free users
/// can create a limited number of collections; Pro unlocks unlimited ones
/// (see `ProFeature.unlimitedCollections`).
///
/// [isPublic] is stored today but only surfaced later (sharing is a
/// fast-follow); it is wired through so the RLS and data model already support
/// it.
class UserCollection extends Equatable {
  const UserCollection({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.coverGameId,
    this.isPublic = false,
    this.gameCount = 0,
    this.createdAt,
    this.updatedAt,
    this.games,
  });

  /// Server-generated UUID.
  final String id;

  /// Owner of the collection (Supabase auth user id).
  final String userId;

  /// Display name, e.g. "Cozy games".
  final String name;

  /// Optional longer description.
  final String? description;

  /// Optional game whose cover art represents the collection.
  final int? coverGameId;

  /// Whether the collection is publicly readable (for later sharing).
  final bool isPublic;

  /// Number of games in the collection. Populated from the aggregate count so
  /// the list can render without loading every game.
  final int gameCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Fully-resolved games, populated only when a detail view loads them.
  final List<Game>? games;

  bool get hasGames => gameCount > 0;
  bool get hasDescription => description != null && description!.isNotEmpty;

  UserCollection copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    int? coverGameId,
    bool? isPublic,
    int? gameCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Game>? games,
  }) {
    return UserCollection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverGameId: coverGameId ?? this.coverGameId,
      isPublic: isPublic ?? this.isPublic,
      gameCount: gameCount ?? this.gameCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      games: games ?? this.games,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        coverGameId,
        isPublic,
        gameCount,
        createdAt,
        updatedAt,
        games,
      ];
}
