import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gamer_grove/features/home/home_screen.dart';
import 'package:gamer_grove/model/igdb_models/collection.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/franchise.dart';
import 'package:gamer_grove/model/igdb_models/game_video.dart';
import 'package:gamer_grove/model/views/eventGridView.dart';
import 'package:gamer_grove/model/views/videosGridView.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/video_player_view.dart';

import '../igdb_models/game.dart';
import '../views/gameGridView.dart';
class EventsStaggeredView extends StatelessWidget{
  final List<Event> events;
  final Color colorPalette;
  final Color headerBorderColor;
  final Color adjustedTextColor;

  const EventsStaggeredView({super.key, required this.events, required this.colorPalette, required this.headerBorderColor, required this.adjustedTextColor});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 8,
          children: [
            if (events.isNotEmpty)
              StaggeredGridTile.count(
                crossAxisCellCount: 3,
                mainAxisCellCount: 2,
                child: EventItemPreview(
                  events: events,
                  color: colorPalette,
                ),
              ),
            if (events.isNotEmpty)
              StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 1,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        AllEventsGridScreen.route(
                            events,
                            context,
                            'Videos'));
                  },
                  child: ClayContainer(
                    spread: 2,
                    depth: 60,
                    borderRadius: 14,
                    color: headerBorderColor,
                    parentColor: headerBorderColor.lighten(40),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: FittedBox(
                        child: Row(
                          children: [
                            Text(
                              'Events',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: adjustedTextColor,
                              ),
                            ),
                            Icon(Icons.navigate_next_rounded)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (events.isNotEmpty)
              StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Container()),
          ]),
    );
  }
}

class EventItemPreview extends StatelessWidget {
  final List<Event> events;
  final Color color;

  const EventItemPreview({
    Key? key,
    required this.events,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final containerBackgroundColor = color.darken(20);
    final headerBorderColor = color;
    final contentBackgroundColor = color.darken(10).withOpacity(.8);

    // Sort the list of events based on their start times
    final sortedEvents = List.from(events)
      ..sort((a, b) => (a.startTime ?? 0).compareTo(b.startTime ?? 0));

    // Select the nearest upcoming event if available,
    // otherwise, select the latest event
    final selectedEvent = sortedEvents.firstWhere(
          (event) => event.startTime != null && event.startTime! > DateTime.now().millisecondsSinceEpoch,
      orElse: () => sortedEvents.last,
    );

    return ClayContainer(
      spread: 2,
      depth: 60,
      borderRadius: 14,
      color: containerBackgroundColor,
      parentColor: headerBorderColor.lighten(40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: EventUI(event: selectedEvent, buildContext: context,),
      ),
    );
  }
}


