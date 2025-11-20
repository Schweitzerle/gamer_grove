// lib/domain/entities/genre.dart
import 'package:equatable/equatable.dart';

class Genre extends Equatable {

  const Genre({
    required this.id,
    required this.checksum,
    required this.name,
    this.slug,
    this.url,
    this.createdAt,
    this.updatedAt,
  });
  final int id;
  final String checksum;
  final String name;
  final String? slug;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    slug,
    url,
    createdAt,
    updatedAt,
  ];
}