import 'package:carousel_slider/carousel_slider.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/views/eventGridView.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:get/get_utils/get_utils.dart';
import '../igdb_models/game.dart';

class EventListView extends StatefulWidget {
  final String headline;
  final List<Event>? events;

  EventListView({
    required this.headline,
    required this.events
  });

  @override
  State<StatefulWidget> createState() => EventListViewState();
}

class EventListViewState extends State<EventListView> {
  @override
  Widget build(BuildContext context) {
    return widget.events != null && widget.events!.isNotEmpty
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                  autoPlayInterval: const Duration(seconds: 10),
                  autoPlayAnimationDuration:
                  const Duration(milliseconds: 4500),
                  autoPlay: true,
                  aspectRatio: 16/9,
                  enableInfiniteScroll: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                  enlargeFactor: .3),
              items: widget.events!
                  .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                    child: EventUI(event: item, buildContext: context),
                  ))
                  .toList(),
            ),
          ],
        )
        : Container();
  }
}
