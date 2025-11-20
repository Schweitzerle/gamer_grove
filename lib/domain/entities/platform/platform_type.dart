// lib/domain/entities/platform_type.dart
import 'package:equatable/equatable.dart';

class PlatformType extends Equatable {

  const PlatformType({
    required this.id,
    required this.checksum,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, checksum, name, createdAt, updatedAt];
}