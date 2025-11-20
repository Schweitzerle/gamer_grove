import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {

  const LeaderboardLoaded(this.users);
  final List<User> users;

  @override
  List<Object> get props => [users];
}

class LeaderboardError extends LeaderboardState {

  const LeaderboardError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
