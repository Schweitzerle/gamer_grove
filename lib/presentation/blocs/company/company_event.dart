// ==================================================
// PLATFORM BLOC EVENTS
// ==================================================

// lib/presentation/blocs/platform/company_event.dart
import 'package:equatable/equatable.dart';

abstract class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object> get props => [];
}

class GetCompanyDetailsEvent extends CompanyEvent {
  final int companyId;
  final bool includeGames;
  final String? userId;

  const GetCompanyDetailsEvent({
    required this.companyId,
    this.includeGames = true,
    this.userId,
  });

  @override
  List<Object> get props => [companyId, includeGames];
}

class ClearCompanyEvent extends CompanyEvent {}
