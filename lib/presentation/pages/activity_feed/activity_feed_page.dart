import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/activity_feed/activity_feed_bloc.dart';
import 'package:gamer_grove/presentation/blocs/activity_feed/activity_feed_event.dart';
import 'package:gamer_grove/presentation/blocs/activity_feed/activity_feed_loading_steps.dart';
import 'package:gamer_grove/presentation/blocs/activity_feed/activity_feed_state.dart';
import 'package:gamer_grove/presentation/pages/activity_feed/widgets/activity_card.dart';
import 'package:gamer_grove/presentation/pages/activity_feed/widgets/activity_content.dart';
import 'package:gamer_grove/presentation/widgets/live_loading_progress.dart';

/// A page that displays the activity feed of the users that the current user follows.
class ActivityFeedPage extends StatefulWidget {
  /// Creates a new [ActivityFeedPage] instance.
  const ActivityFeedPage({super.key});

  @override
  State<ActivityFeedPage> createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage> {
  late ActivityFeedBloc _activityFeedBloc;

  static const Map<ActivityFeedLoadingStep, String> _loadingSteps = {
    ActivityFeedLoadingStep.loadingActivities: 'Loading activities...',
    ActivityFeedLoadingStep.loadingGames: 'Loading games...',
  };

  @override
  void initState() {
    super.initState();
    _activityFeedBloc = sl<ActivityFeedBloc>();
    _activityFeedBloc.add(LoadActivityFeed());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Activity Feed'),
            floating: true,
          ),
          BlocProvider.value(
            value: _activityFeedBloc,
            child: BlocBuilder<ActivityFeedBloc, ActivityFeedState>(
              builder: (context, state) {
                if (state is ActivityFeedLoading) {
                  return SliverFillRemaining(
                    child: Center(
                      child: LiveLoadingProgress(
                        title: 'Loading Activity Feed',
                        steps: _loadingSteps.entries
                            .map((e) => LoadingStep(text: e.value))
                            .toList(),
                      ),
                    ),
                  );
                }
                if (state is ActivityFeedError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(state.message),
                    ),
                  );
                }
                if (state is ActivityFeedLoaded) {
                  if (state.activities.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No activities yet. Follow some users to see their activities.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final activity = state.activities[index];
                        return ActivityCard(
                          activity: activity,
                          content: ActivityContent(
                            activity: activity,
                            games: state.games,
                          ),
                          title: getActivityText(activity.activityType),
                        );
                      },
                      childCount: state.activities.length,
                    ),
                  );
                }
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Something went wrong.'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String getActivityText(String activityType) {
    switch (activityType) {
      case 'rated':
        return 'rated a game';
      case 'recommended':
        return 'recommended a game';
      case 'wishlisted':
        return 'wishlisted a game';
      case 'updated_top_three':
        return 'updated their top three';
      default:
        return 'did something';
    }
  }
}
