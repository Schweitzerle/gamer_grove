import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';

class EventGridView extends StatelessWidget {
  final List<Event> events;

  EventGridView({
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 16/9,
          crossAxisCount: 1,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: EventUI(event: event, buildContext: context)),
          );
        },
        childCount: events.length,
      ),
    );
  }
}

class AllEventsGridScreen extends StatelessWidget {
  static Route route(List<Event> events, BuildContext context, String appBarText) {
    return MaterialPageRoute(
      builder: (context) => AllEventsGridScreen(
        events: events, appBarText: appBarText,
      ),
    );
  }

  final List<Event> events;
  final String appBarText;

  AllEventsGridScreen({required this.events, required this.appBarText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          EventGridView(events: events,),
        ],
      ),
    );
  }
}
