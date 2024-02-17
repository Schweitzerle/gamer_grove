import 'dart:math';

import 'package:accordion/accordion.dart';
import 'package:accordion/accordion_section.dart';
import 'package:accordion/controllers.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/widgets/ageRatingView.dart';
import 'package:gamer_grove/model/widgets/gameModesView.dart';
import 'package:gamer_grove/model/widgets/platform_view.dart';
import 'package:gamer_grove/model/widgets/playerPerspectiveView.dart';
import 'package:gamer_grove/model/widgets/themesView.dart';
import 'package:gamer_grove/model/widgets/website_List.dart';

import '../igdb_models/game.dart';
import 'RatingWidget.dart';
import 'company_view.dart';
import 'game_engine_view.dart';
import 'genresView.dart';
import 'keywordsView.dart';
import 'language_support_table.dart';

class SummaryAndStorylineWidget extends StatefulWidget {
  final Game game;
  final Color color;

  const SummaryAndStorylineWidget(
      {Key? key, required this.game, required this.color})
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

    final headerBorderColor = widget.color;
    final contentBackgroundColor = widget.color.darken(10).withOpacity(.8);
    final containerBackgroundColor = widget.color.darken(20);

    final luminance = headerBorderColor.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
        luminance > targetLuminance ? Colors.black : Colors.white;

    final luminanceContent = headerBorderColor.computeLuminance();
    final adjustedIconColorContent =
    luminanceContent > targetLuminance ? Colors.black : Colors.white;

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
                              isOpen: false,
                              contentVerticalPadding: 10,
                              leftIcon: Icon(
                                Icons.info_rounded,
                                color: adjustedIconColor,
                              ),
                              header: Text(
                                'Info',
                                style: TextStyle(color: adjustedIconColor),
                              ),
                              content: Column(
                                children: [
                                  if (widget.game.genres != null)
                                    GenresList(
                                      genres: widget.game.genres!,
                                      color: widget.color,
                                      headline: 'Genres',
                                    ),
                                  if (widget.game.gameModes != null)
                                    GameModeList(
                                      gameModes: widget.game.gameModes!,
                                      color: widget.color,
                                      headline: 'Game Modes',
                                    ),
                                  if (widget.game.playerPerspectives != null)
                                    PlayerPerspectiveList(
                                      playerPerspective:
                                          widget.game.playerPerspectives!,
                                      color: widget.color,
                                      headline: 'Player Perspectives',
                                    ),
                                  if (widget.game.themes != null)
                                    ThemeList(
                                      themes: widget.game.themes!,
                                      color: widget.color,
                                      headline: 'Themes',
                                    ),
                                  if (widget.game.keywords != null)
                                    KeywordsList(
                                      keywords: widget.game.keywords!,
                                      color: widget.color,
                                      headline: 'Keywords',
                                    ),
                                  if (widget.game.keywords != null)
                                    AgeRatingList(
                                      ageRating: widget.game.ageRatings!,
                                      color: widget.color,
                                      headline: 'Age Ratings',
                                    )
                                ],
                              ),
                            ),
                          ],
                        )
                      : _selectedIndex == 1
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
                                  isOpen: true,
                                  contentVerticalPadding: 10,
                                  leftIcon: Icon(
                                    Icons.list_alt_rounded,
                                    color: adjustedIconColor,
                                  ),
                                  header: Text(
                                    'Summary',
                                    style: TextStyle(color: adjustedIconColor),
                                  ),
                                  content: Center(
                                      child: Text(widget.game.summary != null
                                          ? '${widget.game.summary}'
                                          : 'N/A', style: TextStyle(color: adjustedIconColorContent),)),
                                ),
                              ],
                            )
                          : _selectedIndex == 2
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
                                  headerBackgroundColorOpened:
                                      headerBorderColor,
                                  contentBackgroundColor:
                                      contentBackgroundColor,
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
                                        isOpen: true,
                                        contentVerticalPadding: 10,
                                        leftIcon: Icon(
                                          Icons.menu_book_rounded,
                                          color: adjustedIconColor,
                                        ),
                                        header: Text(
                                          'Storyline',
                                          style: TextStyle(
                                              color: adjustedIconColor),
                                        ),
                                        content: Center(
                                            child: Text(
                                                widget.game.storyline != null
                                                    ? '${widget.game.storyline}'
                                                    : 'N/A',  style: TextStyle(color: adjustedIconColorContent))),
                                      ),
                                    ])
                              : _selectedIndex == 3
                                  ? Accordion(
                                      paddingBetweenClosedSections: 0,
                                      paddingBetweenOpenSections: 0,
                                      paddingListBottom: 0,
                                      paddingListHorizontal: 0,
                                      disableScrolling: true,
                                      headerBorderColor: headerBorderColor,
                                      headerBorderWidth: 4,
                                      headerBackgroundColor:
                                          contentBackgroundColor,
                                      headerBorderColorOpened:
                                          Colors.transparent,
                                      headerBackgroundColorOpened:
                                          headerBorderColor,
                                      contentBackgroundColor:
                                          contentBackgroundColor,
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
                                            contentVerticalPadding: 10,
                                            leftIcon: Icon(
                                              Icons.score_outlined,
                                              color: adjustedIconColor,
                                            ),
                                            header: Text(
                                              'Other Ratings',
                                              style: TextStyle(
                                                  color: adjustedIconColor),
                                            ),
                                            content: Center(
                                                child: Column(
                                              children: [
                                                if (widget.game.aggregatedRating == null &&
                                                    widget.game
                                                            .aggregatedRatingCount ==
                                                        null &&
                                                    widget.game.rating ==
                                                        null &&
                                                    widget.game.ratingCount ==
                                                        null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Center(
                                                      child: Text(
                                                          'No other ratings available'),
                                                    ),
                                                  ),
                                                if (widget.game
                                                            .aggregatedRating !=
                                                        null &&
                                                    widget.game
                                                            .aggregatedRatingCount !=
                                                        null)
                                                  RatingWigdet(
                                                    rating: widget
                                                        .game.aggregatedRating!,
                                                    description:
                                                        'Aggregated Rating based on ${widget.game.aggregatedRatingCount} external critic scores',
                                                    color: widget.color,
                                                  ),
                                                if (widget.game.rating !=
                                                        null &&
                                                    widget.game.ratingCount !=
                                                        null)
                                                  RatingWigdet(
                                                    rating: widget.game.rating!,
                                                    description:
                                                        'Average IGDB user rating based on ${widget.game.ratingCount} users',
                                                    color: widget.color,
                                                  ),
                                              ],
                                            )),
                                          ),
                                        ])
                                  : _selectedIndex == 4
                                      ? Accordion(
                                          paddingBetweenClosedSections: 0,
                                          paddingBetweenOpenSections: 0,
                                          paddingListBottom: 0,
                                          paddingListHorizontal: 0,
                                          disableScrolling: true,
                                          headerBorderColor: headerBorderColor,
                                          headerBorderWidth: 4,
                                          headerBackgroundColor:
                                              contentBackgroundColor,
                                          headerBorderColorOpened:
                                              Colors.transparent,
                                          headerBackgroundColorOpened:
                                              headerBorderColor,
                                          contentBackgroundColor:
                                              contentBackgroundColor,
                                          contentBorderColor: headerBorderColor,
                                          contentBorderWidth: 4,
                                          contentHorizontalPadding: 0,
                                          scaleWhenAnimating: true,
                                          openAndCloseAnimation: true,
                                          headerPadding:
                                              const EdgeInsets.symmetric(
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
                                                Icons.business_rounded,
                                                color: adjustedIconColor,
                                              ),
                                              header: Text(
                                                'Companies and Game Engine',
                                                style: TextStyle(
                                                    color: adjustedIconColor),
                                              ),
                                              content: Center(
                                                  child: Column(
                                                children: [
                                                  if (widget.game
                                                          .involvedCompanies !=
                                                      null)
                                                    InvolvedCompaniesList(
                                                      involvedCompanies: widget
                                                          .game
                                                          .involvedCompanies!,
                                                      lightColor: widget.color,
                                                    ),
                                                  if (widget.game.gameEngines !=
                                                      null)
                                                    GameEngineView(
                                                      gameEngines: widget
                                                          .game.gameEngines!,
                                                      lightColor: widget.color,
                                                    ),
                                                ],
                                              )),
                                            ),
                                          ],
                                        )
                                      : _selectedIndex == 5
                                          ? Accordion(
                                              paddingBetweenClosedSections: 0,
                                              paddingBetweenOpenSections: 0,
                                              paddingListBottom: 0,
                                              paddingListHorizontal: 0,
                                              disableScrolling: true,
                                              headerBorderColor:
                                                  headerBorderColor,
                                              headerBorderWidth: 4,
                                              headerBackgroundColor:
                                                  contentBackgroundColor,
                                              headerBorderColorOpened:
                                                  Colors.transparent,
                                              headerBackgroundColorOpened:
                                                  headerBorderColor,
                                              contentBackgroundColor:
                                                  contentBackgroundColor,
                                              contentBorderColor:
                                                  headerBorderColor,
                                              contentBorderWidth: 4,
                                              contentHorizontalPadding: 0,
                                              scaleWhenAnimating: true,
                                              openAndCloseAnimation: true,
                                              headerPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 7,
                                                      horizontal: 15),
                                              sectionOpeningHapticFeedback:
                                                  SectionHapticFeedback.heavy,
                                              sectionClosingHapticFeedback:
                                                  SectionHapticFeedback.light,
                                              children: [
                                                AccordionSection(
                                                  isOpen: true,
                                                  contentVerticalPadding: 0,
                                                  leftIcon: Icon(
                                                    Icons.language,
                                                    color: adjustedIconColor,
                                                  ),
                                                  header: Text(
                                                    'Language Support',
                                                    style: TextStyle(
                                                        color:
                                                            adjustedIconColor),
                                                  ),
                                                  content: Center(
                                                      child: Column(
                                                    children: [
                                                      if (widget.game
                                                              .languageSupports !=
                                                          null)
                                                        LanguageSupportTable(
                                                          languageSupports: widget
                                                              .game
                                                              .languageSupports!,
                                                          color: widget.color,
                                                        ),
                                                    ],
                                                  )),
                                                ),
                                              ],
                                            )
                                          : _selectedIndex == 6 ?  Accordion(
                                              paddingBetweenClosedSections: 0,
                                              paddingBetweenOpenSections: 0,
                                              paddingListBottom: 0,
                                              paddingListHorizontal: 0,
                                              disableScrolling: true,
                                              headerBorderColor:
                                                  headerBorderColor,
                                              headerBorderWidth: 4,
                                              headerBackgroundColor:
                                                  contentBackgroundColor,
                                              headerBorderColorOpened:
                                                  Colors.transparent,
                                              headerBackgroundColorOpened:
                                                  headerBorderColor,
                                              contentBackgroundColor:
                                                  contentBackgroundColor,
                                              contentBorderColor:
                                                  headerBorderColor,
                                              contentBorderWidth: 4,
                                              contentHorizontalPadding: 0,
                                              scaleWhenAnimating: true,
                                              openAndCloseAnimation: true,
                                              headerPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 7,
                                                      horizontal: 15),
                                              sectionOpeningHapticFeedback:
                                                  SectionHapticFeedback.heavy,
                                              sectionClosingHapticFeedback:
                                                  SectionHapticFeedback.light,
                                              children: [
                                                AccordionSection(
                                                  isOpen: true,
                                                  contentVerticalPadding: 0,
                                                  leftIcon: Icon(
                                                    Icons.devices_rounded,
                                                    color: adjustedIconColor,
                                                  ),
                                                  header: Text(
                                                    'Platforms',
                                                    style: TextStyle(
                                                        color:
                                                            adjustedIconColor),
                                                  ),
                                                  content: Center(
                                                      child: Column(
                                                    children: [
                                                      if (widget
                                                              .game.platforms !=
                                                          null)
                                                        PlatformView(
                                                            game: widget.game,
                                                            color:
                                                                headerBorderColor),
                                                    ],
                                                  )),
                                                ),
                                              ],
                                            ) : Accordion(
                    paddingBetweenClosedSections: 0,
                    paddingBetweenOpenSections: 0,
                    paddingListBottom: 0,
                    paddingListHorizontal: 0,
                    disableScrolling: true,
                    headerBorderColor:
                    headerBorderColor,
                    headerBorderWidth: 4,
                    headerBackgroundColor:
                    contentBackgroundColor,
                    headerBorderColorOpened:
                    Colors.transparent,
                    headerBackgroundColorOpened:
                    headerBorderColor,
                    contentBackgroundColor:
                    contentBackgroundColor,
                    contentBorderColor:
                    headerBorderColor,
                    contentBorderWidth: 4,
                    contentHorizontalPadding: 0,
                    scaleWhenAnimating: true,
                    openAndCloseAnimation: true,
                    headerPadding:
                    const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 15),
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
                          style: TextStyle(
                              color:
                              adjustedIconColor),
                        ),
                        content: Center(
                            child: Column(
                              children: [
                                if (widget.game.websites != null)
                                  WebsiteList(websites: widget.game.websites!, lightColor: widget.color,),
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
      case 4:
        iconData = Icons.business_rounded;
        break;
      case 5:
        iconData = Icons.language;
        break;
      case 6:
        iconData = Icons.devices_rounded;
        break;
      case 7:
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
    if (widget.game.involvedCompanies != null) values.add(4);
    if (widget.game.languageSupports != null) values.add(5);
    if (widget.game.platforms != null) values.add(6);
    if (widget.game.websites != null) values.add(7);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}
