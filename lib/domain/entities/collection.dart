// lib/domain/entities/collection.dart
import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? url;
  final List<int> gameIds;

  const Collection({
    required this.id,
    required this.name,
    required this.slug,
    this.url,
    this.gameIds = const [],
  });

  @override
  List<Object?> get props => [id, name, slug, url, gameIds];
}


