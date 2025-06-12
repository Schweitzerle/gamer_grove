// domain/entities/genre.dart
import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  final int id;
  final String name;
  final String slug;

  const Genre({
    required this.id,
    required this.name,
    required this.slug,
  });

  @override
  List<Object> get props => [id, name, slug];
}

