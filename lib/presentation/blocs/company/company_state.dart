import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/company/company.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyDetailsLoaded extends CompanyState {

  const CompanyDetailsLoaded({
    required this.company,
    required this.games,
  });
  final Company company;
  final List<Game> games;

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [company, games];
}

class CompanyError extends CompanyState {

  const CompanyError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
