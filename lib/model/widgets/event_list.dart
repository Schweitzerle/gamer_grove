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
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
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
    /*SizedBox(
              height: mediaQueryHeight * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClayContainer(
                    depth: 60,
                    spread: 2,
                    customBorderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        widget.headline,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .cardTheme
                                .surfaceTintColor),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(AllEventsGridScreen.route(widget.events!, context, widget.headline));                    },
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'All',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .cardTheme
                                .surfaceTintColor),
                      ),
                    ),
                  )
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.events!.length,
                itemBuilder: (context, index) {
                  if (index >= widget.events!.length) {
                    return null; // or a placeholder widget
                  }
                  Event event = widget.events![index];
                  return AspectRatio(aspectRatio: 16/9,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EventUI(
                        event: event,
                        buildContext: context,
                      ),
                    ),
                  );
                },
              ),
            ),*/
          ],
        )
        : Container();
  }
}
