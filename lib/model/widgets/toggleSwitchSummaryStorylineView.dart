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
import 'package:gamer_grove/model/widgets/ageRatingView.dart';
import 'package:gamer_grove/model/widgets/gameModesView.dart';
import 'package:gamer_grove/model/widgets/playerPerspectiveView.dart';
import 'package:gamer_grove/model/widgets/themesView.dart';

import '../igdb_models/game.dart';
import 'RatingWidget.dart';
import 'genresView.dart';
import 'keywordsView.dart';

class SummaryAndStorylineWidget extends StatefulWidget {
  final Game game;
  final Color darkColor;
  final Color lightColor;

  const SummaryAndStorylineWidget(
      {Key? key,
      required this.game,
      required this.darkColor,
      required this.lightColor})
      : super(key: key);

  @override
  _SummaryAndStorylineWidgetState createState() =>
      _SummaryAndStorylineWidgetState();
}

class _SummaryAndStorylineWidgetState extends State<SummaryAndStorylineWidget> {
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
              width: mediaQueryWidth * .4,
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
            padding: EdgeInsets.only(top: mediaQueryHeight * .04),
            child: SizedBox(
                child: _selectedIndex == 0
                    ? Accordion(
                        disableScrolling: true,
                        headerBorderColor: widget.lightColor,
                        headerBorderWidth: 4,
                        headerBackgroundColor: widget.darkColor,
                        headerBorderColorOpened: Colors.transparent,
                        headerBackgroundColorOpened: widget.lightColor,
                        contentBackgroundColor:
                            Theme.of(context).colorScheme.background,
                        contentBorderColor: widget.lightColor,
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
                            leftIcon: const Icon(
                              Icons.info_rounded,
                            ),
                            header: const Text(
                              'Info',
                            ),
                            content: Column(
                              children: [
                                if (widget.game.genres != null)
                                  GenresList(
                                    genres: widget.game.genres!,
                                    color: widget.lightColor,
                                    headline: 'Genres',
                                  ),
                                if (widget.game.gameModes != null)
                                  GameModeList(
                                    gameModes: widget.game.gameModes!,
                                    color: widget.lightColor,
                                    headline: 'Game Modes',
                                  ),
                                if (widget.game.playerPerspectives != null)
                                  PlayerPerspectiveList(
                                    playerPerspective:
                                        widget.game.playerPerspectives!,
                                    color: widget.lightColor,
                                    headline: 'Player Perspectives',
                                  ),
                                if (widget.game.themes != null)
                                  ThemeList(
                                    themes: widget.game.themes!,
                                    color: widget.lightColor,
                                    headline: 'Themes',
                                  ),
                                if (widget.game.keywords != null)
                                  KeywordsList(
                                    keywords: widget.game.keywords!,
                                    color: widget.lightColor,
                                    headline: 'Keywords',
                                  ),
                                if (widget.game.keywords != null)
                                  AgeRatingList(
                                    ageRating: widget.game.ageRatings!,
                                    color: widget.lightColor,
                                    headline: 'Age Ratings',
                                  )
                              ],
                            ),
                          ),
                        ],
                      )
                    : _selectedIndex == 1
                        ? Accordion(
                            disableScrolling: true,
                            headerBorderColor: widget.lightColor,
                            headerBorderWidth: 4,
                            headerBackgroundColor: widget.darkColor,
                            headerBorderColorOpened: Colors.transparent,
                            headerBackgroundColorOpened: widget.lightColor,
                            contentBackgroundColor:
                                Theme.of(context).colorScheme.background,
                            contentBorderColor: widget.lightColor,
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
                                isOpen: true,
                                contentVerticalPadding: 10,
                                leftIcon: const Icon(
                                  Icons.list_alt_rounded,
                                ),
                                header: const Text(
                                  'Summary',
                                ),
                                content: Center(
                                    child: Text(widget.game.summary != null
                                        ? '${widget.game.summary}'
                                        : 'N/A')),
                              ),
                            ],
                          )
                        : _selectedIndex == 2
                            ? Accordion(
                                headerBorderColor: widget.lightColor,
                                headerBorderWidth: 4,
                                headerBackgroundColor: widget.darkColor,
                                headerBorderColorOpened: Colors.transparent,
                                headerBackgroundColorOpened: widget.lightColor,
                                contentBackgroundColor:
                                    Theme.of(context).colorScheme.background,
                                contentBorderColor: widget.lightColor,
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
                                      isOpen: true,
                                      contentVerticalPadding: 10,
                                      leftIcon: const Icon(
                                        Icons.menu_book_rounded,
                                      ),
                                      header: const Text(
                                        'Storyline',
                                      ),
                                      content: Center(
                                          child: Text(
                                              widget.game.storyline != null
                                                  ? '${widget.game.storyline}'
                                                  : 'N/A')),
                                    ),
                                  ])
                            : Accordion(
                                headerBorderColor: widget.lightColor,
                                headerBorderWidth: 4,
                                headerBackgroundColor: widget.darkColor,
                                headerBorderColorOpened: Colors.transparent,
                                headerBackgroundColorOpened: widget.lightColor,
                                contentBackgroundColor:
                                    Theme.of(context).colorScheme.background,
                                contentBorderColor: widget.lightColor,
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
                                      isOpen: true,
                                      contentVerticalPadding: 10,
                                      leftIcon: const Icon(
                                        Icons.menu_book_rounded,
                                      ),
                                      header: const Text(
                                        'Other Ratings',
                                      ),
                                      content: Center(
                                          child: Column(
                                        children: [
                                          if (widget.game.aggregatedRating ==
                                                  null &&
                                              widget.game
                                                      .aggregatedRatingCount ==
                                                  null &&
                                              widget.game.rating == null &&
                                              widget.game.ratingCount == null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Text(
                                                    'No other ratings available'),
                                              ),
                                            ),
                                          if (widget.game.aggregatedRating !=
                                                  null &&
                                              widget.game
                                                      .aggregatedRatingCount !=
                                                  null)
                                            RatingWigdet(
                                              rating:
                                                  widget.game.aggregatedRating!,
                                              description:
                                                  'Aggregated Rating based on ${widget.game.aggregatedRatingCount} external critic scores',
                                              color: widget.lightColor,
                                            ),
                                          if (widget.game.rating != null &&
                                              widget.game.ratingCount != null)
                                            RatingWigdet(
                                              rating: widget.game.rating!,
                                              description:
                                                  'Average IGDB user rating based on ${widget.game.ratingCount} users',
                                              color: widget.lightColor,
                                            ),
                                        ],
                                      )),
                                    ),
                                  ])),
          ),
        ],
      ),
    );
  }

  Widget iconBuilder(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.info_rounded;
        break;
      case 1:
        iconData = Icons.list_alt_rounded;
        break;
      case 2:
        iconData = Icons.menu_book_rounded;
        break;
      case 3:
        iconData = Icons.score_outlined;
        break;
      // Add more cases if needed
      default:
        iconData = Icons.error;
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
          : value == 1
              ? widget.darkColor.darken(10)
              : value == 2
                  ? widget.darkColor.darken(15)
                  : widget.darkColor.darken(20),
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
    if (widget.game.genres != null ||
        widget.game.gameModes != null ||
        widget.game.playerPerspectives != null ||
        widget.game.keywords != null ||
        widget.game.themes != null) values.add(0);
    if (widget.game.summary != null) values.add(1);
    if (widget.game.storyline != null) values.add(2);
    if (widget.game.aggregatedRatingCount != null ||
        widget.game.aggregatedRating != null ||
        widget.game.ratingCount != null ||
        widget.game.rating != null) values.add(3);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}
