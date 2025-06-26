// lib/domain/entities/involved_company.dart
import 'package:equatable/equatable.dart';
import 'company.dart';

class InvolvedCompany extends Equatable {
  final int id;
  final Company company;
  final bool isDeveloper;
  final bool isPublisher;
  final bool isPorting;
  final bool isSupporting;

  const InvolvedCompany({
    required this.id,
    required this.company,
    this.isDeveloper = false,
    this.isPublisher = false,
    this.isPorting = false,
    this.isSupporting = false,
  });

  @override
  List<Object> get props => [id, company, isDeveloper, isPublisher, isPorting, isSupporting];
}
