import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:marquee/marquee.dart';
import 'package:palette_generator/palette_generator.dart';

import 'circular_rating_widget.dart'; // Stellen Sie sicher, dass der Importpfad korrekt ist

class EventUI extends StatefulWidget {
  final Event event;
  final BuildContext buildContext;

  const EventUI({Key? key, required this.event, required this.buildContext})
      : super(key: key);

  @override
  _EventUIState createState() => _EventUIState();
}






//TODO: wenn url null, dann zeigt es den container gar nicht mehr an







class _EventUIState extends State<EventUI> {
  late Color colorpalette;
  late Color lightColor;
  late Color darkColor;
  bool isColorLoaded = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    setState(() {
      colorpalette = Theme
          .of(widget.buildContext)
          .colorScheme
          .inversePrimary;
      lightColor = Theme
          .of(widget.buildContext)
          .colorScheme
          .primary;
      darkColor = Theme
          .of(widget.buildContext)
          .colorScheme
          .background;
    });
    await Future.wait([getColorPalette()]);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery
        .of(context)
        .size
        .height;
    final mediaQueryWidth = MediaQuery
        .of(context)
        .size
        .width;

    final coverScaleWidth = mediaQueryWidth / 2.2;
    final coverScaleHeight = mediaQueryHeight / 2.3;

    return InkWell(
      onTap: () {
        //TODO: Navigator.of(context).push(GameDetailScreen.route(widget.game, context));
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClayContainer(
          color: darkColor,
          spread: 2,
          depth: 60,
          borderRadius: 14,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: CachedNetworkImage(
                  imageUrl: '${widget.event.eventLogo?.url}',
                  placeholder: (context, url) =>
                      Container(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .tertiaryContainer,
                      ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.grey,
                        ),
                        padding: EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: FittedBox(
                                child: Icon(
                                  FontAwesomeIcons.calendarDay,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 5,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Center(
                                  child: Text(
                                    _calculateDaysText(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: Marquee(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        fadingEdgeEndFraction: 0.9,
                        fadingEdgeStartFraction: 0.1,
                        blankSpace: 200,
                        pauseAfterRound: Duration(seconds: 4),
                        text: '${widget.event.name}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDaysText() {
    if (widget.event.startTime != null) {
      final currentTime = DateTime.now();
      final startTime = DateTime.fromMillisecondsSinceEpoch(widget.event.startTime! * 1000);
      final difference = startTime.difference(currentTime);
      final daysDifference = difference.inDays;

      if (daysDifference > 0) {
        return 'In {$daysDifference} d';
      } else if (daysDifference < 0) {
        return '${daysDifference.abs()} d ago';
      } else {
        return 'Today';
      }
    } else {
      return '';
    }
  }


  Future<void> getColorPalette() async {
    if (widget.event.eventLogo!.url != null) {
      final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        NetworkImage('${widget.event.eventLogo!.url}'),
        size: Size(100, 150),
        maximumColorCount: 10,
      );
      setState(() {
        colorpalette = paletteGenerator.dominantColor?.color ??
            Theme
                .of(widget.buildContext)
                .colorScheme
                .inversePrimary;
        lightColor = paletteGenerator.lightVibrantColor?.color ??
            Theme
                .of(widget.buildContext)
                .colorScheme
                .primary;
        darkColor = paletteGenerator.darkVibrantColor?.color ??
            Theme
                .of(widget.buildContext)
                .colorScheme
                .background;
        isColorLoaded = true;
      });
    }
  }
}

