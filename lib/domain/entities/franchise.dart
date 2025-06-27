// lib/domain/entities/franchise.dart
import 'package:equatable/equatable.dart';

class Franchise extends Equatable {
  final int id;
  final String checksum;
  final String name;
  final String? slug;
  final String? url;
  final List<int> gameIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Franchise({
    required this.id,
    required this.checksum,
    required this.name,
    this.slug,
    this.url,
    this.gameIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  bool get hasGames => gameIds.isNotEmpty;
  int get gameCount => gameIds.length;

  // Check if this is a major franchise (has many games)
  bool get isMajorFranchise => gameCount >= 5;
  bool get isSmallFranchise => gameCount <= 3;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    slug,
    url,
    gameIds,
    createdAt,
    updatedAt,
  ];
}