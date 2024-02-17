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
import 'package:gamer_grove/model/widgets/gameModesView.dart';
import 'package:gamer_grove/model/widgets/playerPerspectiveView.dart';
import 'package:gamer_grove/model/widgets/themesView.dart';

import '../igdb_models/game.dart';
import 'RatingWidget.dart';
import 'genresView.dart';
import 'imagePreview.dart';
import 'keywordsView.dart';

class ImagesContainerSwitchWidget extends StatefulWidget {
  final Game game;
  final Color color;

  const ImagesContainerSwitchWidget(
      {Key? key,
      required this.game,
      required this.color})
      : super(key: key);

  @override
  _ImagesContainerSwitchWidgetState createState() =>
      _ImagesContainerSwitchWidgetState();
}

class _ImagesContainerSwitchWidgetState
    extends State<ImagesContainerSwitchWidget> {
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

    if(widget.game.artworks == null && widget.game.screenshots == null) { return Container();}
      return  Padding(
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
                      ? ImagePreview(game: widget.game, isArtwork: false)
                      : ImagePreview(game: widget.game, isArtwork: true)),
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
        iconData = Icons.screenshot_monitor_rounded;
        break;
      case 1:
        iconData = Icons.brush_rounded;
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
    if (widget.game.screenshots != null) values.add(0);
    if (widget.game.artworks != null) values.add(1);
    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}
