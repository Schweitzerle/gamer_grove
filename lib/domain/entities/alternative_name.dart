// lib/domain/entities/alternative_name.dart
import 'package:equatable/equatable.dart';

class AlternativeName extends Equatable {

  const AlternativeName({
    required this.id,
    required this.checksum,
    required this.name,
    this.comment,
    this.gameId,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String? comment;
  final int? gameId;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    checksum,
    comment,
    gameId,
    name,
    createdAt,
    updatedAt,
  ];
}