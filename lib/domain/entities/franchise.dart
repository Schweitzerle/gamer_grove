// lib/domain/entities/franchise.dart
import 'package:equatable/equatable.dart';

class Franchise extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? url;

  const Franchise({
    required this.id,
    required this.name,
    required this.slug,
    this.url,
  });

  @override
  List<Object?> get props => [id, name, slug, url];
}

