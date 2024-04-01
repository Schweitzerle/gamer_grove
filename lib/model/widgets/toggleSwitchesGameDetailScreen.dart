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
import 'package:gamer_grove/model/widgets/platform_view.dart';
import 'package:gamer_grove/model/widgets/playerPerspectiveView.dart';
import 'package:gamer_grove/model/widgets/themesView.dart';
import 'package:gamer_grove/model/widgets/video_view.dart';
import 'package:gamer_grove/model/widgets/website_List.dart';

import '../igdb_models/game.dart';
import 'RatingWidget.dart';
import 'ageRatingView.dart';
import 'characters_view.dart';
import 'collection_view.dart';
import 'company_view.dart';
import 'events_view.dart';
import 'followingGameRatings.dart';
import 'franchise_view.dart';
import 'gameListPreview.dart';
import 'game_engine_view.dart';
import 'genresView.dart';
import 'imagePreview.dart';
import 'keywordsView.dart';
import 'language_support_table.dart';

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
      required this.characters,
      required this.adjustedTextColor})
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

    final containerBackgroundColor = widget.color.darken(10);
    final headerBorderColor = widget.color;

    if (widget.game.franchises != null ||
        widget.game.collection != null ||
        widget.game.videos != null ||
        widget.events.isNotEmpty ||
        widget.characters.isNotEmpty) {
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
                padding: EdgeInsets.only(top: mediaQueryHeight * .057),
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
                                      adjustedTextColor:
                                          widget.adjustedTextColor)
                                  : CharactersStaggeredView(
                                      characters: widget.characters,
                                      colorPalette: widget.color,
                                      headerBorderColor: headerBorderColor,
                                      adjustedTextColor:
                                          widget.adjustedTextColor),
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
        iconData = Icons.lan_outlined;
        break;
      case 1:
        iconData = Icons.photo_library_outlined;
        break;
      case 2:
        iconData = Icons.ondemand_video;
        break;
      case 3:
        iconData = Icons.event;
        break;
      case 4:
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
    if (widget.game.franchises != null && widget.game.franchises![0].games != null) values.add(0);
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
    final containerBackgroundColor = widget.color.darken(10);

    final luminance = headerBorderColor.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
        luminance > targetLuminance ? Colors.black : Colors.white;

    final luminanceContent = headerBorderColor.computeLuminance();
    final adjustedIconColorContent =
        luminanceContent > targetLuminance ? Colors.black : Colors.white;

    if (widget.game.genres != null ||
        widget.game.gameModes != null ||
        widget.game.playerPerspectives != null ||
        widget.game.keywords != null ||
        widget.game.themes != null ||
        widget.game.summary != null ||
        widget.game.storyline != null ||
        widget.game.aggregatedRatingCount != null ||
        widget.game.aggregatedRating != null ||
        widget.game.ratingCount != null ||
        widget.game.rating != null ||
        widget.game.involvedCompanies != null ||
        widget.game.languageSupports != null ||
        widget.game.platforms != null ||
        widget.game.websites != null) {
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
                padding: EdgeInsets.only(top: mediaQueryHeight * .04, bottom: mediaQueryHeight * .008),
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
                                    if (widget.game.ageRatings != null)
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
                                      style:
                                          TextStyle(color: adjustedIconColor),
                                    ),
                                    content: Center(
                                        child: Text(
                                      widget.game.summary != null
                                          ? '${widget.game.summary}'
                                          : 'N/A',
                                      style: TextStyle(
                                          color: adjustedIconColorContent),
                                    )),
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
                                    headerBackgroundColor:
                                        contentBackgroundColor,
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
                                                      : 'N/A',
                                                  style: TextStyle(
                                                      color:
                                                          adjustedIconColorContent))),
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
                                                      widget.game.aggregatedRatingCount ==
                                                          null &&
                                                      widget.game.rating ==
                                                          null &&
                                                      widget.game.ratingCount ==
                                                          null)
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(
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
                                                      rating: widget.game
                                                          .aggregatedRating!,
                                                      description:
                                                          'Aggregated Rating based on ${widget.game.aggregatedRatingCount} external critic scores',
                                                      color: widget.color,
                                                    ),
                                                  if (widget.game.rating !=
                                                          null &&
                                                      widget.game.ratingCount !=
                                                          null)
                                                    RatingWigdet(
                                                      rating:
                                                          widget.game.rating!,
                                                      description:
                                                          'Average IGDB user rating based on ${widget.game.ratingCount} users',
                                                      color: widget.color,
                                                    ),
                                                  FollowingGameRatings(game: widget.game, color: headerBorderColor,),
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
                                                        lightColor:
                                                            widget.color,
                                                      ),
                                                    if (widget
                                                            .game.gameEngines !=
                                                        null)
                                                      GameEngineView(
                                                        gameEngines: widget
                                                            .game.gameEngines!,
                                                        lightColor:
                                                            widget.color,
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
                                            : _selectedIndex == 6
                                                ? Accordion(
                                                    paddingBetweenClosedSections:
                                                        0,
                                                    paddingBetweenOpenSections:
                                                        0,
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
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 7,
                                                            horizontal: 15),
                                                    sectionOpeningHapticFeedback:
                                                        SectionHapticFeedback
                                                            .heavy,
                                                    sectionClosingHapticFeedback:
                                                        SectionHapticFeedback
                                                            .light,
                                                    children: [
                                                      AccordionSection(
                                                        isOpen: true,
                                                        contentVerticalPadding:
                                                            0,
                                                        leftIcon: Icon(
                                                          Icons.devices_rounded,
                                                          color:
                                                              adjustedIconColor,
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
                                                            if (widget.game
                                                                    .platforms !=
                                                                null)
                                                              PlatformView(
                                                                  game: widget
                                                                      .game,
                                                                  color:
                                                                      headerBorderColor),
                                                          ],
                                                        )),
                                                      ),
                                                    ],
                                                  )
                                                : Accordion(
                                                    paddingBetweenClosedSections:
                                                        0,
                                                    paddingBetweenOpenSections:
                                                        0,
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
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 7,
                                                            horizontal: 15),
                                                    sectionOpeningHapticFeedback:
                                                        SectionHapticFeedback
                                                            .heavy,
                                                    sectionClosingHapticFeedback:
                                                        SectionHapticFeedback
                                                            .light,
                                                    children: [
                                                      AccordionSection(
                                                        isOpen: true,
                                                        contentVerticalPadding:
                                                            0,
                                                        leftIcon: Icon(
                                                          Icons.link_sharp,
                                                          color:
                                                              adjustedIconColor,
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
                                                            if (widget.game
                                                                    .websites !=
                                                                null)
                                                              WebsiteList(
                                                                websites: widget
                                                                    .game
                                                                    .websites!,
                                                                lightColor:
                                                                    widget
                                                                        .color,
                                                              ),
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
        values.add(3);
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

class ImagesContainerSwitchWidget extends StatefulWidget {
  final Game game;
  final Color color;

  const ImagesContainerSwitchWidget(
      {Key? key, required this.game, required this.color})
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

    final containerBackgroundColor = widget.color.darken(10);
    final headerBorderColor = widget.color;

    if (widget.game.artworks != null || widget.game.screenshots != null) {
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
                padding: EdgeInsets.only(top: mediaQueryHeight * .053),
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
    return Container();
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

    final containerBackgroundColor = widget.color.darken(10);
    final headerBorderColor = widget.color;
    final contentBackgroundColor = widget.color.darken(10).withOpacity(.8);

    if (widget.game.parentGame != null ||
        widget.game.versionParent != null ||
        widget.game.dlcs != null ||
        widget.game.remakes != null ||
        widget.game.remasters != null ||
        widget.game.bundles != null ||
        widget.game.expandedGames != null ||
        widget.game.expansions != null ||
        widget.game.standaloneExpansions != null ||
        widget.game.forks != null ||
        widget.game.ports != null ||
        widget.game.similarGames != null) {
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
                padding: EdgeInsets.only(top: mediaQueryHeight * .062),
                child: SizedBox(
                    child: _selectedIndex == 0
                        ? GameListView(
                            color: headerBorderColor,
                            headline: 'Parent Game',
                            games: widget.game.parentGame != null
                                ? [
                                    widget.game.parentGame!
                                  ]
                                : [],
                            isPagination: false,
                            body: '',
                            showLimit: 5, isAggregated: false,
                          )
                        : _selectedIndex == 1
                            ? GameListView(
                                color: headerBorderColor,
                                headline: 'Version Parent',
                                games: widget.game.versionParent != null
                                    ? [
                                        widget.game.versionParent!
                                      ]
                                    : [],
                                isPagination: false,
                                body: '',
                                showLimit: 5, isAggregated: false,
                              )
                            : _selectedIndex == 2
                                ? GameListView(
                                    color: headerBorderColor,
                                    headline: 'DLCs',
                                    games: widget.game.dlcs,
                                    isPagination: false,
                                    body: '',
                                    showLimit: 5, isAggregated: false,
                                  )
                                : _selectedIndex == 3
                                    ? GameListView(
                                        color: headerBorderColor,
                                        headline: 'Remakes',
                                        games: widget.game.remakes,
                                        isPagination: false,
                                        body: '',
                                        showLimit: 5, isAggregated: false,
                                      )
                                    : _selectedIndex == 4
                                        ? GameListView(
                                            color: headerBorderColor,
                                            headline: 'Remasters',
                                            games: widget.game.remasters,
                                            isPagination: false,
                                            body: '',
                                            showLimit: 5, isAggregated: false,
                                          )
                                        : _selectedIndex == 5
                                            ? GameListView(
                                                color: headerBorderColor,
                                                headline: 'Bundles',
                                                games: widget.game.bundles,
                                                isPagination: false,
                                                body: '',
                                                showLimit: 5, isAggregated: false,
                                              )
                                            : _selectedIndex == 6
                                                ? GameListView(
                                                    color: headerBorderColor,
                                                    headline: 'Expanded Games',
                                                    games: widget
                                                        .game.expandedGames,
                                                    isPagination: false,
                                                    body: '',
                                                    showLimit: 5, isAggregated: false,
                                                  )
                                                : _selectedIndex == 7
                                                    ? GameListView(
                                                        color:
                                                            headerBorderColor,
                                                        headline: 'Expansions',
                                                        games: widget
                                                            .game.expansions,
                                                        isPagination: false,
                                                        body: '',
                                                        showLimit: 5, isAggregated: false,
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
                                                            showLimit: 5, isAggregated: false,
                                                          )
                                                        : _selectedIndex == 9
                                                            ? GameListView(
                                                                color:
                                                                    headerBorderColor,
                                                                headline:
                                                                    'Forks',
                                                                games: widget
                                                                    .game.forks,
                                                                isPagination:
                                                                    false,
                                                                body: '',
                                                                showLimit: 5, isAggregated: false,
                                                              )
                                                            : _selectedIndex ==
                                                                    10
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
                                                                    showLimit:
                                                                        5, isAggregated: false,
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
                                                                    showLimit:
                                                                        5, isAggregated: false,
                                                                  )),
              )
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
