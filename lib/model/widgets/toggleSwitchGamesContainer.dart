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
import 'gameListPreview.dart';
import 'RatingWidget.dart';
import 'gamePreview.dart';
import 'genresView.dart';
import 'imagePreview.dart';
import 'keywordsView.dart';

class GamesContainerSwitchWidget extends StatefulWidget {
  final Game game;
  final Color darkColor;
  final Color lightColor;

  const GamesContainerSwitchWidget(
      {Key? key,
      required this.game,
      required this.darkColor,
      required this.lightColor})
      : super(key: key);

  @override
  _GamesContainerSwitchWidgetState createState() =>
      _GamesContainerSwitchWidgetState();
}

class _GamesContainerSwitchWidgetState
    extends State<GamesContainerSwitchWidget> {
  late int _selectedIndex;
  final List<int> values = [];

  @override
  void initState() {
    init();
    super.initState();
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.lightColor.withOpacity(.5),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: mediaQueryWidth,
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
          Padding(
            padding: EdgeInsets.only(top: mediaQueryHeight * .052),
            child: SizedBox(
              child: _selectedIndex == 0
                  ? GameListView(
                headline: 'Bundles',
                games: widget.game.bundles,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 1
                  ? GameListView(
                headline: 'DLCs',
                games: widget.game.dlcs,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 2
                  ? GameListView(
                headline: 'Expanded Games',
                games: widget.game.expandedGames,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 3
                  ? GameListView(
                headline: 'Expansions',
                games: widget.game.expansions,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 4
                  ? GameListView(
                headline: 'Forks',
                games: widget.game.forks,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 5
                  ? GameListView(
                headline: 'Ports',
                games: widget.game.ports,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 6
                  ? GameListView(
                headline: 'Remakes',
                games: widget.game.remakes,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 7
                  ? GameListView(
                headline: 'Remasters',
                games: widget.game.remasters,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 8
                  ? GameListView(
                headline: 'Similar Games',
                games: widget
                    .game.similarGames,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 9
                  ? GameListView(
                headline:
                'Standalone Expansions',
                games: widget.game
                    .standaloneExpansions,
                isPagination: false,
                body: '',
                showLimit: 5,
              )
                  : _selectedIndex == 10
                  ? GameListView(
                headline:
                'Parent Game',
                games: widget.game
                    .parentGame !=
                    null
                    ? [
                  widget
                      .game
                      .parentGame!
                ] // Das einzelne Game-Objekt in eine Liste platzieren
                    : [],
                // Eine leere Liste übergeben, wenn parentGame null ist
                isPagination:
                false,
                body: '',
                showLimit: 5,
              )
                  : GameListView(
                headline:
                'Version Parent',
                games: widget.game
                    .versionParent !=
                    null
                    ? [
                  widget
                      .game
                      .versionParent!
                ] // Das einzelne Game-Objekt in eine Liste platzieren
                    : [],
                isPagination:
                false,
                body: '',
                showLimit: 5,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget iconBuilder(int index) {
    IconData iconData;
    switch (index) {
      default:
        iconData = Icons.videogame_asset_outlined;
    }

    return Icon(
      iconData,
      color: widget.lightColor.darken(10), // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilder(int value) {
    return ToggleStyle(
      indicatorColor:
      value == 0 ? widget.darkColor : widget.darkColor.darken(10),
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

  void init() {
    if (widget.game.bundles != null) values.add(0);
    if (widget.game.dlcs != null) values.add(1);
    if (widget.game.expandedGames != null) values.add(2);
    if (widget.game.expansions != null) values.add(3);
    if (widget.game.forks != null) values.add(4);
    if (widget.game.ports != null) values.add(5);
    if (widget.game.remasters != null) values.add(6);
    if (widget.game.remakes != null) values.add(7);
    if (widget.game.similarGames != null) values.add(8);
    if (widget.game.standaloneExpansions != null) values.add(9);
    if (widget.game.parentGame != null) values.add(10);
    if (widget.game.versionParent != null) values.add(11);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}
