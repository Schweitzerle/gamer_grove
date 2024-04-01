import 'dart:math';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/website.dart';
import 'package:gamer_grove/model/widgets/RatingWidget.dart';
import 'package:gamer_grove/model/widgets/bannerImage.dart';
import 'package:gamer_grove/model/widgets/characterListPreview.dart';
import 'package:gamer_grove/model/widgets/character_view.dart';
import 'package:gamer_grove/model/widgets/characters_view.dart';
import 'package:gamer_grove/model/widgets/circular_rating_widget.dart';
import 'package:gamer_grove/model/widgets/collection_view.dart';
import 'package:gamer_grove/model/widgets/company_view.dart';
import 'package:gamer_grove/model/widgets/countUpRow.dart';
import 'package:gamer_grove/model/widgets/event_list.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/events_view.dart';
import 'package:gamer_grove/model/widgets/franchise_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/game_engine_view.dart';
import 'package:gamer_grove/model/widgets/imagePreview.dart';
import 'package:gamer_grove/model/widgets/infoRow.dart';
import 'package:gamer_grove/model/widgets/platform_view.dart';
import 'package:gamer_grove/model/widgets/toggleSwitchesEventsDetailScreen.dart';
import 'package:gamer_grove/model/widgets/toggleSwitchesGameDetailScreen.dart';

import 'package:gamer_grove/model/widgets/video_list.dart';
import 'package:gamer_grove/model/widgets/video_player_view.dart';
import 'package:gamer_grove/model/widgets/video_view.dart';
import 'package:gamer_grove/model/widgets/website_List.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:motion/motion.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../singleton/sinlgleton.dart';
import 'dart:developer';

import '../widgets/language_support_table.dart';
import '../widgets/gameListPreview.dart';
import '../widgets/shimmerGameItem.dart';
import 'gameGridView.dart';

class EventDetailScreen extends StatefulWidget {
  static Route route(Event event, BuildContext context) {
    return MaterialPageRoute(
      builder: (context) => EventDetailScreen(
        event: event,
        context: context,
      ),
    );
  }

  final Event event;
  final BuildContext context;

  EventDetailScreen({required this.event, required this.context});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Color colorPalette;
  late Color lightColor;
  late Color darkColor;
  late PaletteColor color;
  bool isColorLoaded = false;
  final apiService = IGDBApiService();

  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      colorPalette = Theme.of(widget.context).colorScheme.inversePrimary;
      lightColor = Theme.of(widget.context).colorScheme.primary;
      darkColor = Theme.of(widget.context).colorScheme.background;
    });
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([getColorPalette()]);
  }

  Future<List<dynamic>> getIGDBData() async {
    final apiService = IGDBApiService();
    try {
      final body = '''
     
    query events "Game Events" {
      fields checksum, created_at, description, end_time, event_logo.*, event_networks.*, games.*, games.cover.*, games.artworks.*, live_stream_url, name, slug, start_time, time_zone, updated_at, videos.*;
      where id = ${widget.event.id};
    };
    ''';

      final List<dynamic> response =
          await apiService.getIGDBData(IGDBAPIEndpointsEnum.multiquery, body);

     return response;

    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
    return [];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> getColorPalette() async {
    if (widget.event.eventLogo != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage('${widget.event.eventLogo!.url}'),
        size: Size(100, 150), // Adjust the image size as needed
        maximumColorCount: 10, // Adjust the maximum color count as needed
      );
      setState(() {
        color = paletteGenerator.dominantColor!;
        colorPalette = paletteGenerator.dominantColor?.color ??
            Theme.of(widget.context).colorScheme.inversePrimary;
        lightColor = paletteGenerator.lightVibrantColor?.color ??
            Theme.of(widget.context).colorScheme.primary;
        darkColor = paletteGenerator.darkVibrantColor?.color ??
            Theme.of(widget.context).colorScheme.background;
        isColorLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final coverScaleHeight = mediaQueryHeight / 3.2;
    final coverScaleWidth = coverScaleHeight * 0.66;
    final bannerScaleHeight = mediaQueryHeight * 0.3;

    final coverPaddingScaleHeight = mediaQueryHeight * 0.14;

    final containerBackgroundColor = colorPalette.darken(10);
    final headerBorderColor = colorPalette;
    final contentBackgroundColor = colorPalette.darken(10).withOpacity(.8);

    final luminance = headerBorderColor.computeLuminance();
    final targetLuminance = 0.5;
    final adjustedTextColor =
        luminance > targetLuminance ? Colors.black : Colors.white;

    //TODO: Banner nicht scrollable machen
    return Scaffold(
      body: Container(
        height: mediaQueryHeight,
        width: mediaQueryWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.0, 0.9), // Start at the middle left
            end: Alignment(0.0, 0.4), // End a little above the middle
            colors: [
              colorPalette.lighten(10),
              colorPalette.darken(40),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 8.0, right: 8, top: coverPaddingScaleHeight),
                    child: Column(
                      children: [
                        Motion(
                          glare: GlareConfiguration(
                            color: colorPalette.lighten(20),
                            minOpacity: 0,
                          ),
                          shadow: const ShadowConfiguration(
                              color: Colors.black, blurRadius: 2, opacity: .2),
                          borderRadius: BorderRadius.circular(14),
                          child: EventUI(
                            event: widget.event,
                            buildContext: context,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        // Additional Info Rows
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              widget.event.startTime != null
                                  ? InfoRow.buildInfoRow(
                                      FontAwesomeIcons.hourglassStart,
                                      '${DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(widget.event.startTime! * 1000))} ${widget.event.timeZone}',
                                      containerBackgroundColor,
                                      Color(0xffff6961),
                                      false,
                                      context)
                                  : Container(),
                              widget.event.endTime != null
                                  ?  InfoRow.buildInfoRow(
                                  FontAwesomeIcons.hourglassEnd,
                                  '${DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(widget.event.endTime! * 1000))} ${widget.event.timeZone}',
                                  containerBackgroundColor,
                                      Color(0xffffb480),
                                      false,
                                      context)
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text above GamePreviewView
                  Padding(
                    padding: EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: coverPaddingScaleHeight / 2),
                    child: FittedBox(
                      child: GlassContainer(
                        blur: 12,
                        shadowStrength: 4,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(14),
                        shadowColor: colorPalette,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            widget.event.name!.isNotEmpty
                                ? widget.event.name!
                                : 'Loading...',
                            speed: Duration(milliseconds: 150),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),
                  ),
                    )
                  )
                ],
              ),
              SizedBox(
                height: mediaQueryHeight * .01,
              ),
              if (isColorLoaded)
                FutureBuilder<List<dynamic>>(
                  future: getIGDBData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final response = snapshot.data!;
                      List<Event> events = [];

                      final eventsResponse = response.firstWhere(
                              (item) => item['name'] == 'Game Events',
                          orElse: () => null);
                      if (eventsResponse != null) {
                        events = apiService.parseResponseToEvent(eventsResponse['result']);
                      }

                      return   Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (events.isNotEmpty)
                            EventInfoWidget(
                                event: events[0], color: colorPalette),
                          if (events.isNotEmpty)
                            EventsVideosContainerSwitchWidget(
                              event: events[0], color: colorPalette, adjustedTextColor: adjustedTextColor,),
                          if (events.isNotEmpty)
                            EventGamesContainerSwitchWidget(
                              event: events[0],
                              color: colorPalette,
                            ),
                          const SizedBox(
                            height: 14,
                          )
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    // Display a loading indicator while fetching data
                    return ShimmerItem.buildShimmerEventDetailScreen(context);
                  }),

            ],
          ),
        ),
      ),
    );
  }
}
