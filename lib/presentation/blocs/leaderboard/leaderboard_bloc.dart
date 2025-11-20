import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/usecases/user/get_leaderboard_users.dart';
import 'package:gamer_grove/presentation/blocs/leaderboard/leaderboard_event.dart';
import 'package:gamer_grove/presentation/blocs/leaderboard/leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {

  LeaderboardBloc({required this.getLeaderboardUsers}) : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }
  final GetLeaderboardUsersUseCase getLeaderboardUsers;

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
