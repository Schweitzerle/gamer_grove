// lib/domain/entities/platform_family.dart
import 'package:equatable/equatable.dart';

class PlatformFamily extends Equatable {

  const PlatformFamily({
    required this.id,
    required this.checksum,
    required this.name,
    this.slug,
  });
  final int id;
  final String checksum;
  final String name;
  final String? slug;

  @override
  List<Object?> get props => [id, checksum, name, slug];
}