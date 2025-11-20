// ===== COMPANY STATUS ENTITY =====
// lib/domain/entities/company/company_status.dart
import 'package:equatable/equatable.dart';

class CompanyStatus extends Equatable {

  const CompanyStatus({
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

  // Helper getters
  bool get isActive => name.toLowerCase().contains('active');
  bool get isDefunct => name.toLowerCase().contains('defunct') ||
      name.toLowerCase().contains('closed');

  @override
  List<Object?> get props => [
    id,
    checksum,
    name,
    createdAt,
    updatedAt,
  ];
}
