import 'dart:math';

import 'package:accordion/accordion.dart';
import 'package:accordion/accordion_section.dart';
import 'package:accordion/controllers.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
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
  final Color darkColor;
  final Color lightColor;

  const ImagesContainerSwitchWidget(
      {Key? key,
      required this.game,
      required this.darkColor,
      required this.lightColor})
      : super(key: key);

  @override
  _ImagesContainerSwitchWidgetState createState() =>
      _ImagesContainerSwitchWidgetState();
}

class _ImagesContainerSwitchWidgetState
    extends State<ImagesContainerSwitchWidget> {
  int _selectedIndex = 0; // Index des ausgewählten Abschnitts

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: mediaQueryWidth * .4,
              height: mediaQueryHeight * .06,
              //TODO: noch irgwie den ausgewählten text zu dem container anzeigen in einer reihe oder so
              child: AnimatedToggleSwitch<int>.size(
                textDirection: TextDirection.ltr,
                current: _selectedIndex,
                values: const [0, 1,],
                iconOpacity: 0.2,
                indicatorSize: const Size.fromWidth(100),
                iconBuilder: iconBuilder,
                borderWidth: 4.0,
                iconAnimationType: AnimationType.onHover,
                style: ToggleStyle(
                  borderColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
                styleBuilder: styleBuilder,
                onChanged: (i) => setState(() => _selectedIndex = i),

              ),
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
      color: widget.lightColor.darken(10), // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilder(int value) {
    return ToggleStyle(
      indicatorColor: value == 0
          ? widget.darkColor
          :widget.darkColor.darken(10),
      borderColor: Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
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
}
