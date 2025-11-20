// lib/domain/entities/collection/collection.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game.dart'; // 🆕 Add this import

class Collection extends Equatable { // Populated when fetched for UI

  const Collection({
    required this.id,
    required this.checksum,
    required this.name,
    this.slug,
    this.url,
    this.asChildRelationIds = const [],
    this.asParentRelationIds = const [],
    this.gameIds = const [],
    this.typeId,
    this.createdAt,
    this.updatedAt,
    this.games, // 🆕 Add this parameter
  });
  final int id;
  final String checksum;
  final String name;
  final String? slug;
  final String? url;
  final List<int> asChildRelationIds;
  final List<int> asParentRelationIds;
  final List<int> gameIds;
  final int? typeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // 🆕 NEW: Add games property for UI display
  final List<Game>? games;

  // Helper getters
  bool get hasGames => gameIds.isNotEmpty;
  bool get hasChildRelations => asChildRelationIds.isNotEmpty;
  bool get hasParentRelations => asParentRelationIds.isNotEmpty;
  bool get hasRelations => hasChildRelations || hasParentRelations;
  int get gameCount => gameIds.length;

  // Check if this collection is part of a hierarchy
  bool get isPartOfHierarchy => hasRelations;
  bool get isParentCollection => hasChildRelations;
  bool get isChildCollection => hasParentRelations;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    slug,
    url,
    asChildRelationIds,
    asParentRelationIds,
    gameIds,
    typeId,
    createdAt,
    updatedAt,
    games, // 🆕 Add this to props
  ];
}