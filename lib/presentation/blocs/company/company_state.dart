import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/company/company.dart';
import '../../../domain/entities/game/game.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyDetailsLoaded extends CompanyState {
  final Company company;
  final List<Game> games;

  const CompanyDetailsLoaded({
    required this.company,
    required this.games,
  });

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [company, games];
}

class CompanyError extends CompanyState {
  final String message;

  const CompanyError({required this.message});

  @override
  List<Object> get props => [message];
}
