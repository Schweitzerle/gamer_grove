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
  final Color color;

  const GamesContainerSwitchWidget(
      {Key? key, required this.game, required this.color})
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
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final containerBackgroundColor = widget.color.darken(20);
    final headerBorderColor = widget.color;
    final contentBackgroundColor = widget.color.darken(10).withOpacity(.8);

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
                      ? GameListView(
                          color: headerBorderColor,
                          headline: 'Parent Game',
                          games: widget.game.parentGame != null
                              ? [
                                  widget.game.parentGame!
                                ] // Das einzelne Game-Objekt in eine Liste platzieren
                              : [],
                          // Eine leere Liste übergeben, wenn parentGame null ist
                          isPagination: false,
                          body: '',
                          showLimit: 5,
                        )
                      : _selectedIndex == 1
                          ? GameListView(
                              color: headerBorderColor,
                              headline: 'Version Parent',
                              games: widget.game.versionParent != null
                                  ? [
                                      widget.game.versionParent!
                                    ] // Das einzelne Game-Objekt in eine Liste platzieren
                                  : [],
                              isPagination: false,
                              body: '',
                              showLimit: 5,
                            )
                          : _selectedIndex == 2
                              ? GameListView(
                                  color: headerBorderColor,
                                  headline: 'DLCs',
                                  games: widget.game.dlcs,
                                  isPagination: false,
                                  body: '',
                                  showLimit: 5,
                                )
                              : _selectedIndex == 3
                                  ? GameListView(
                                      color: headerBorderColor,
                                      headline: 'Remakes',
                                      games: widget.game.remakes,
                                      isPagination: false,
                                      body: '',
                                      showLimit: 5,
                                    )
                                  : _selectedIndex == 4
                                      ? GameListView(
                                          color: headerBorderColor,
                                          headline: 'Remasters',
                                          games: widget.game.remasters,
                                          isPagination: false,
                                          body: '',
                                          showLimit: 5,
                                        )
                                      : _selectedIndex == 5
                                          ? GameListView(
                                              color: headerBorderColor,
                                              headline: 'Bundles',
                                              games: widget.game.bundles,
                                              isPagination: false,
                                              body: '',
                                              showLimit: 5,
                                            )
                                          : _selectedIndex == 6
                                              ? GameListView(
                                                  color: headerBorderColor,
                                                  headline: 'Expanded Games',
                                                  games:
                                                      widget.game.expandedGames,
                                                  isPagination: false,
                                                  body: '',
                                                  showLimit: 5,
                                                )
                                              : _selectedIndex == 7
                                                  ? GameListView(
                                                      color: headerBorderColor,
                                                      headline: 'Expansions',
                                                      games: widget
                                                          .game.expansions,
                                                      isPagination: false,
                                                      body: '',
                                                      showLimit: 5,
                                                    )
                                                  : _selectedIndex == 8
                                                      ? GameListView(
                                                          color:
                                                              headerBorderColor,
                                                          headline:
                                                              'Standalone Expansions',
                                                          games: widget.game
                                                              .standaloneExpansions,
                                                          isPagination: false,
                                                          body: '',
                                                          showLimit: 5,
                                                        )
                                                      : _selectedIndex == 9
                                                          ? GameListView(
                                                              color:
                                                                  headerBorderColor,
                                                              headline: 'Forks',
                                                              games: widget
                                                                  .game.forks,
                                                              isPagination:
                                                                  false,
                                                              body: '',
                                                              showLimit: 5,
                                                            )
                                                          : _selectedIndex == 10
                                                              ? GameListView(
                                                                  color:
                                                                      headerBorderColor,
                                                                  headline:
                                                                      'Ports',
                                                                  games: widget
                                                                      .game
                                                                      .ports,
                                                                  isPagination:
                                                                      false,
                                                                  body: '',
                                                                  showLimit: 5,
                                                                )
                                                              : GameListView(
                                                                  color:
                                                                      headerBorderColor,
                                                                  headline:
                                                                      'Similar Games',
                                                                  games: widget
                                                                      .game
                                                                      .similarGames,
                                                                  isPagination:
                                                                      false,
                                                                  body: '',
                                                                  showLimit: 5,
                                                                )),
            )
          ],
        ),
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
    if (widget.game.parentGame != null) values.add(0);
    if (widget.game.versionParent != null) values.add(1);
    if (widget.game.dlcs != null && widget.game.dlcs!.isNotEmpty) values.add(2);
    if (widget.game.remakes != null && widget.game.remakes!.isNotEmpty)
      values.add(3);
    if (widget.game.remasters != null && widget.game.remasters!.isNotEmpty)
      values.add(4);
    if (widget.game.bundles != null && widget.game.bundles!.isNotEmpty)
      values.add(5);
    if (widget.game.expandedGames != null &&
        widget.game.expandedGames!.isNotEmpty) values.add(6);
    if (widget.game.expansions != null && widget.game.expansions!.isNotEmpty)
      values.add(7);
    if (widget.game.standaloneExpansions != null &&
        widget.game.standaloneExpansions!.isNotEmpty) values.add(8);
    if (widget.game.forks != null && widget.game.forks!.isNotEmpty)
      values.add(9);
    if (widget.game.ports != null && widget.game.ports!.isNotEmpty)
      values.add(10);
    if (widget.game.similarGames != null &&
        widget.game.similarGames!.isNotEmpty) values.add(11);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}
