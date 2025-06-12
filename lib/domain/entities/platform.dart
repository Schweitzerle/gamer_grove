// domain/entities/platform.dart
import 'package:equatable/equatable.dart';

class Platform extends Equatable {
  final int id;
  final String name;
  final String abbreviation;
  final String? logoUrl;

  const Platform({
    required this.id,
    required this.name,
    required this.abbreviation,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [id, name, abbreviation, logoUrl];
}
