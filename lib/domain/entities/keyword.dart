// lib/domain/entities/keyword.dart
import 'package:equatable/equatable.dart';

class Keyword extends Equatable {
  final int id;
  final String name;
  final String slug;

  const Keyword({
    required this.id,
    required this.name,
    required this.slug,
  });

  @override
  List<Object> get props => [id, name, slug];
}