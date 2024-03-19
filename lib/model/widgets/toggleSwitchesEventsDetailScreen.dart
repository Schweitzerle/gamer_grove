import 'dart:math';

import 'package:accordion/accordion.dart';
import 'package:accordion/accordion_section.dart';
import 'package:accordion/controllers.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/firebase/firebaseUser.dart';
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/widgets/companyWebsite_List.dart';
import 'package:gamer_grove/model/widgets/gameModesView.dart';
import 'package:gamer_grove/model/widgets/platform_view.dart';
import 'package:gamer_grove/model/widgets/playerPerspectiveView.dart';
import 'package:gamer_grove/model/widgets/themesView.dart';
import 'package:gamer_grove/model/widgets/video_view.dart';
import 'package:gamer_grove/model/widgets/website_List.dart';
import 'package:url_launcher/url_launcher.dart';

import '../firebase/gameModel.dart';
import '../igdb_models/game.dart';
import 'RatingWidget.dart';
import 'ageRatingView.dart';
import 'characters_view.dart';
import 'collection_view.dart';
import 'company_view.dart';
import 'events_view.dart';
import 'franchise_view.dart';
import 'gameListPreview.dart';
import 'game_engine_view.dart';
import 'genresView.dart';
import 'imagePreview.dart';
import 'keywordsView.dart';
import 'language_support_table.dart';

class EventInfoWidget extends StatefulWidget {
  final Event event;
  final Color color;

  const EventInfoWidget(
      {Key? key, required this.event, required this.color})
      : super(key: key);

  @override
  _EventInfoWidgetState createState() => _EventInfoWidgetState();
}

class _EventInfoWidgetState extends State<EventInfoWidget> {
  late int _selectedIndex; // Index des ausgewählten Abschnitts
  final List<int> values = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final headerBorderColor = widget.color;
    final contentBackgroundColor = widget.color.darken(10).withOpacity(.8);
    final containerBackgroundColor = widget.color.darken(10);

    final luminance = headerBorderColor.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
        luminance > targetLuminance ? Colors.black : Colors.white;

    final luminanceContent = headerBorderColor.computeLuminance();
    final adjustedIconColorContent =
        luminanceContent > targetLuminance ? Colors.black : Colors.white;

    if (widget.event.description != null || widget.event.liveStreamUrl != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16, top: 24),
        child: ClayContainer(
          spread: 2,
          depth: 60,
          borderRadius: 14,
          color: containerBackgroundColor,
          parentColor: headerBorderColor.lighten(40),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: mediaQueryHeight * .06,
                  child: AnimatedToggleSwitch<int>.size(
                    textDirection: TextDirection.ltr,
                    current: _selectedIndex,
                    values: values,
                    iconOpacity: 0.2,
                    indicatorSize: const Size.fromWidth(100),
                    iconBuilder: iconBuilder,
                    borderWidth: 4.0,
                    iconAnimationType: AnimationType.onHover,
                    style: ToggleStyle(
                      backgroundColor: containerBackgroundColor,
                      borderColor: containerBackgroundColor,
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          color: containerBackgroundColor,
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    styleBuilder: styleBuilder,
                    onChanged: (i) => setState(() => _selectedIndex = i),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: mediaQueryHeight * .04),
                child: SizedBox(
                    child: _selectedIndex == 0
                        ? Accordion(
                            paddingBetweenClosedSections: 0,
                            paddingBetweenOpenSections: 0,
                            paddingListBottom: 0,
                            paddingListHorizontal: 0,
                            disableScrolling: true,
                            headerBorderColor: headerBorderColor,
                            headerBorderWidth: 4,
                            headerBackgroundColor: contentBackgroundColor,
                            headerBorderColorOpened: Colors.transparent,
                            headerBackgroundColorOpened: headerBorderColor,
                            contentBackgroundColor: contentBackgroundColor,
                            contentBorderColor: headerBorderColor,
                            contentBorderWidth: 4,
                            contentHorizontalPadding: 10,
                            scaleWhenAnimating: true,
                            openAndCloseAnimation: true,
                            headerPadding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 15),
                            sectionOpeningHapticFeedback:
                                SectionHapticFeedback.heavy,
                            sectionClosingHapticFeedback:
                                SectionHapticFeedback.light,
                            children: [
                              AccordionSection(
                                isOpen: false,
                                contentVerticalPadding: 10,
                                leftIcon: Icon(
                                  Icons.info_rounded,
                                  color: adjustedIconColor,
                                ),
                                header: Text(
                                  'Description',
                                  style: TextStyle(color: adjustedIconColor),
                                ),
                                content: Center(
                                    child: Text(
                                  widget.event.description != null
                                      ? '${widget.event.description}'
                                      : 'N/A',
                                  style: TextStyle(
                                      color: adjustedIconColorContent),
                                )),
                              ),
                            ],
                          )
                        : Accordion(
                            paddingBetweenClosedSections: 0,
                            paddingBetweenOpenSections: 0,
                            paddingListBottom: 0,
                            paddingListHorizontal: 0,
                            disableScrolling: true,
                            headerBorderColor: headerBorderColor,
                            headerBorderWidth: 4,
                            headerBackgroundColor: contentBackgroundColor,
                            headerBorderColorOpened: Colors.transparent,
                            headerBackgroundColorOpened: headerBorderColor,
                            contentBackgroundColor: contentBackgroundColor,
                            contentBorderColor: headerBorderColor,
                            contentBorderWidth: 4,
                            contentHorizontalPadding: 0,
                            scaleWhenAnimating: true,
                            openAndCloseAnimation: true,
                            headerPadding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 15),
                            sectionOpeningHapticFeedback:
                                SectionHapticFeedback.heavy,
                            sectionClosingHapticFeedback:
                                SectionHapticFeedback.light,
                            children: [
                              AccordionSection(
                                isOpen: true,
                                contentVerticalPadding: 0,
                                leftIcon: Icon(
                                  Icons.link_sharp,
                                  color: adjustedIconColor,
                                ),
                                header: Text(
                                  'Links',
                                  style: TextStyle(color: adjustedIconColor),
                                ),
                                content: Center(
                                    child: Column(
                                  children: [
                                    if (widget.event.liveStreamUrl != null)
                                      GestureDetector(
                                        onTap: () {
                                          _launchURL(widget.event.liveStreamUrl);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(4.0),
                                          child: const Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.all(8.0),
                                                child: Icon(Icons.live_tv_rounded,
                                                    color: Color(0xFF07355A)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                )),
                              ),
                            ],
                          )),
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Future<void> _launchURL(String? urlString) async {
    final Uri url = Uri.parse(urlString!);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget iconBuilder(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.info_rounded;
        break;
      case 1:
        iconData = Icons.business_rounded;
        break;
      case 2:
        iconData = Icons.link_sharp;
        break;
      default:
        iconData = Icons.error;
    }

    return Icon(
      iconData,
      color: widget.color.lighten(40), // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilder(int value) {
    return ToggleStyle(
      indicatorColor: widget.color.lighten(40).withOpacity(.5),
      borderColor: Colors.transparent,
      borderRadius: BorderRadius.circular(14.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          spreadRadius: 1,
          blurRadius: 2,
          offset: Offset(0, 1.5),
        ),
      ],
    );
  }

  void init() {
    if (widget.event.description != null) values.add(0);
    if (widget.event.liveStreamUrl != null) values.add(2);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}

class EventGamesContainerSwitchWidget extends StatefulWidget {
  final Event event;
  final Color color;

  const EventGamesContainerSwitchWidget(
      {Key? key, required this.event, required this.color})
      : super(key: key);

  @override
  _EventGamesContainerSwitchWidgetState createState() =>
      _EventGamesContainerSwitchWidgetState();
}

class _EventGamesContainerSwitchWidgetState
    extends State<EventGamesContainerSwitchWidget> {
  late int _selectedIndex;
  final List<int> values = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final containerBackgroundColor = widget.color.darken(10);
    final headerBorderColor = widget.color;
    final contentBackgroundColor = widget.color.darken(10).withOpacity(.8);

    if (widget.event.games != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16, top: 24),
        child: ClayContainer(
          spread: 2,
          depth: 60,
          borderRadius: 14,
          color: containerBackgroundColor,
          parentColor: headerBorderColor.lighten(40),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: mediaQueryHeight * .06,
                  child: AnimatedToggleSwitch<int>.size(
                    textDirection: TextDirection.ltr,
                    current: _selectedIndex,
                    values: values,
                    iconOpacity: 0.2,
                    indicatorSize: const Size.fromWidth(100),
                    iconBuilder: iconBuilder,
                    borderWidth: 4.0,
                    iconAnimationType: AnimationType.onHover,
                    style: ToggleStyle(
                      backgroundColor: containerBackgroundColor,
                      borderColor: containerBackgroundColor,
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          color: containerBackgroundColor,
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    styleBuilder: styleBuilder,
                    onChanged: (i) => setState(() => _selectedIndex = i),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: mediaQueryHeight * .058),
                  child: SizedBox(
                      child: _selectedIndex == 0
                          ? GameListView(
                              color: headerBorderColor,
                              headline: 'Featured Games',
                              games: widget.event.games!,
                              // Eine leere Liste übergeben, wenn parentGame null ist
                              isPagination: false,
                              body: '',
                              showLimit: 5, isAggregated: false,
                            )
                          : Container()))
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget iconBuilder(int index) {
    IconData iconData;
    switch (index) {
      default:
        iconData = Icons.videogame_asset_outlined;
    }

    return Icon(
      iconData,
      color: widget.color.lighten(40), // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilder(int value) {
    return ToggleStyle(
      indicatorColor: widget.color.lighten(40).withOpacity(.5),
      borderColor: Colors.transparent,
      borderRadius: BorderRadius.circular(14.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          spreadRadius: 1,
          blurRadius: 2,
          offset: Offset(0, 1.5),
        ),
      ],
    );
  }

  void init() {
    if (widget.event.games != null) values.add(0);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}


class EventsVideosContainerSwitchWidget extends StatefulWidget {
  final Event event;
  final Color color;
  final Color adjustedTextColor;

  const EventsVideosContainerSwitchWidget(
      {Key? key,
        required this.event,
        required this.color,
        required this.adjustedTextColor})
      : super(key: key);

  @override
  _EventsVideosContainerSwitchWidgetState createState() =>
      _EventsVideosContainerSwitchWidgetState();
}

class _EventsVideosContainerSwitchWidgetState
    extends State<EventsVideosContainerSwitchWidget> {
  late int _selectedIndex;
  final List<int> values = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final containerBackgroundColor = widget.color.darken(10);
    final headerBorderColor = widget.color;

    if (widget.event.videos != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16, top: 24),
        child: ClayContainer(
          spread: 2,
          depth: 60,
          borderRadius: 14,
          color: containerBackgroundColor,
          parentColor: headerBorderColor.lighten(40),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: mediaQueryHeight * .06,
                  //TODO: noch irgwie den ausgewählten text zu dem container anzeigen in einer reihe oder so
                  child: AnimatedToggleSwitch<int>.size(
                    textDirection: TextDirection.ltr,
                    current: _selectedIndex,
                    values: values,
                    iconOpacity: 0.2,
                    indicatorSize: const Size.fromWidth(100),
                    iconBuilder: iconBuilder,
                    borderWidth: 4.0,
                    iconAnimationType: AnimationType.onHover,
                    style: ToggleStyle(
                      backgroundColor: containerBackgroundColor,
                      borderColor: containerBackgroundColor,
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          color: containerBackgroundColor,
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    styleBuilder: styleBuilder,
                    onChanged: (i) => setState(() => _selectedIndex = i),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: mediaQueryHeight * .057),
                child: SizedBox(
                  child: _selectedIndex == 0
                      ? VideoStaggeredView(
                      game: Game(id: 0, videos: widget.event.videos, gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0)),
                      colorPalette: widget.color,
                      headerBorderColor: headerBorderColor,
                      adjustedTextColor: widget.adjustedTextColor)
                      : Container()

                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget iconBuilder(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.photo_library_outlined;
        break;
      default:
        iconData = Icons.image;
    }

    return Icon(
      iconData,
      color: widget.color.lighten(40), // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilder(int value) {
    return ToggleStyle(
      indicatorColor: widget.color.lighten(40).withOpacity(.5),
      borderColor: Colors.transparent,
      borderRadius: BorderRadius.circular(14.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          spreadRadius: 1,
          blurRadius: 2,
          offset: Offset(0, 1.5),
        ),
      ],
    );
  }

  void init() {
    if (widget.event.videos != null) values.add(0);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}
