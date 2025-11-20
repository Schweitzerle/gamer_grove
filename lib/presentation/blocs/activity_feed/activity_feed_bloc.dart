import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/user/get_activity_feed.dart';
import 'package:gamer_grove/presentation/blocs/activity_feed/activity_feed_event.dart';
import 'package:gamer_grove/presentation/blocs/activity_feed/activity_feed_loading_steps.dart';
import 'package:gamer_grove/presentation/blocs/activity_feed/activity_feed_state.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';

class ActivityFeedBloc extends Bloc<ActivityFeedEvent, ActivityFeedState> {

  ActivityFeedBloc({
    required this.getActivityFeed,
    required this.gameRepository,
    required this.authBloc,
  }) : super(ActivityFeedInitial()) {
    on<LoadActivityFeed>(_onLoadActivityFeed);
  }
  final GetActivityFeedUseCase getActivityFeed;
  final GameRepository gameRepository;
  final AuthBloc authBloc;

  Future<void> _onLoadActivityFeed(
    LoadActivityFeed event,
    Emitter<ActivityFeedState> emit,
  ) async {
    final authState = authBloc.state;
    if (authState is AuthAuthenticated) {
      emit(const ActivityFeedLoading(
          ActivityFeedLoadingStep.loadingActivities, 0,),);
      final activityResult = await getActivityFeed(authState.user.id);
      await activityResult.fold(
        (failure) async => emit(ActivityFeedError(failure.message)),
        (activities) async {
          emit(const ActivityFeedLoading(
              ActivityFeedLoadingStep.loadingGames, 0.5,),);
          final gameIds = activities
              .map((activity) {
                if (activity.gameId != null) {
                  return activity.gameId;
                } else if (activity.activityType == 'updated_top_three' &&
                    activity.metadata != null) {
                  return (
                    activity.metadata!['game_1_id'] as int?,
                    activity.metadata!['game_2_id'] as int?,
                    activity.metadata!['game_3_id'] as int?,
                  );
                }
                return null;
              })
              .expand((element) {
                if (element is int) {
                  return [element];
                } else if (element is (int?, int?, int?)) {
                  return [element.$1, element.$2, element.$3].whereType<int>();
                }
                return <int>[];
              })
              .toSet()
              .toList();

          if (gameIds.isEmpty) {
            emit(ActivityFeedLoaded(activities, const []));
            return;
          }

          final gameResult = await gameRepository.getGames(gameIds: gameIds);
          gameResult.fold(
            (failure) => emit(ActivityFeedError(failure.message)),
            (games) => emit(ActivityFeedLoaded(activities, games)),
          );
        },
      );
    } else {
      emit(const ActivityFeedError('User not authenticated'));
    }
  }
}
