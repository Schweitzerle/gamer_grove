// lib/data/models/franchise_model.dart
import '../../domain/entities/franchise.dart';

class FranchiseModel extends Franchise {
  const FranchiseModel({
    required super.id,
    required super.name,
    required super.slug,
    super.url,
  });

  factory FranchiseModel.fromJson(Map<String, dynamic> json) {
    return FranchiseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Franchise',
      slug: json['slug'] ?? json['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? 'unknown',
      url: json['url'],
    );
  }
}