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
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/widgets/gameModesView.dart';
import 'package:gamer_grove/model/widgets/playerPerspectiveView.dart';
import 'package:gamer_grove/model/widgets/themesView.dart';
import 'package:gamer_grove/model/widgets/video_view.dart';

import '../igdb_models/game.dart';
import 'RatingWidget.dart';
import 'characters_view.dart';
import 'collection_view.dart';
import 'events_view.dart';
import 'franchise_view.dart';
import 'genresView.dart';
import 'imagePreview.dart';
import 'keywordsView.dart';

class CollectionsEventsContainerSwitchWidget extends StatefulWidget {
  final Game game;
  final List<Event> events;
  final List<Character> characters;
  final Color color;
  final Color adjustedTextColor;

  const CollectionsEventsContainerSwitchWidget(
      {Key? key,
      required this.game,
      required this.color,
      required this.events,
      required this.characters, required this.adjustedTextColor})
      : super(key: key);

  @override
  _CollectionsEventsContainerSwitchWidgetState createState() =>
      _CollectionsEventsContainerSwitchWidgetState();
}

class _CollectionsEventsContainerSwitchWidgetState
    extends State<CollectionsEventsContainerSwitchWidget> {
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

    final containerBackgroundColor = widget.color.darken(20);
    final headerBorderColor = widget.color;

    if (widget.game.artworks == null && widget.game.screenshots == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                    backgroundColor: containerBackgroundColor.darken(8),
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
              padding: EdgeInsets.only(top: mediaQueryHeight * .052),
              child: SizedBox(
                child: _selectedIndex == 0
                    ? FranchiseStaggeredView(
                        game: widget.game,
                        colorPalette: widget.color,
                        headerBorderColor: headerBorderColor,
                        adjustedTextColor: widget.adjustedTextColor)
                    : _selectedIndex == 1
                        ? CollectionStaggeredView(
                            game: widget.game,
                            colorPalette: widget.color,
                            headerBorderColor: headerBorderColor,
                            adjustedTextColor: widget.adjustedTextColor)
                        : _selectedIndex == 2
                            ? VideoStaggeredView(
                                game: widget.game,
                                colorPalette: widget.color,
                                headerBorderColor: headerBorderColor,
                                adjustedTextColor: widget.adjustedTextColor)
                            : _selectedIndex == 3
                                ? EventsStaggeredView(
                                    events: widget.events,
                                    colorPalette: widget.color,
                                    headerBorderColor: headerBorderColor,
                                    adjustedTextColor: widget.adjustedTextColor)
                                : CharactersStaggeredView(
                                    characters: widget.characters,
                                    colorPalette: widget.color,
                                    headerBorderColor: headerBorderColor,
                                    adjustedTextColor: widget.adjustedTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget iconBuilder(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.lan_outlined;
        break;
      case 1:
        iconData = Icons.photo_library_outlined;
        break;
      case 1:
        iconData = Icons.ondemand_video;
        break;
      case 1:
        iconData = Icons.event;
        break;
      case 1:
        iconData = Icons.groups;
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
    if (widget.game.franchises != null) values.add(0);
    if (widget.game.collection != null) values.add(1);
    if (widget.game.videos != null) values.add(2);
    if (widget.events.isNotEmpty) values.add(3);
    if (widget.characters.isNotEmpty) values.add(4);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}
