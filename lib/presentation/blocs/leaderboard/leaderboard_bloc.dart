import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/usecases/user/get_leaderboard_users.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboardUsersUseCase getLeaderboardUsers;

  LeaderboardBloc({required this.getLeaderboardUsers}) : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    final result = await getLeaderboardUsers();
    result.fold(
      (failure) => emit(LeaderboardError(failure.message)),
      (users) => emit(LeaderboardLoaded(users)),
    );
  }
}
