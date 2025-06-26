// lib/domain/entities/company.dart
import 'package:equatable/equatable.dart';

class Company extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? country;
  final String? website;
  final DateTime? foundedDate;
  final List<String> aliases;

  const Company({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.country,
    this.website,
    this.foundedDate,
    this.aliases = const [],
  });

  @override
  List<Object?> get props => [id, name, description, logoUrl, country, website, foundedDate, aliases];
}