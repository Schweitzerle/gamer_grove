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
import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/widgets/companyWebsite_List.dart';
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
import 'franchise_view.dart';
import 'gameListPreview.dart';
import 'game_engine_view.dart';
import 'genresView.dart';
import 'imagePreview.dart';
import 'keywordsView.dart';
import 'language_support_table.dart';

class CompanyInfoWidget extends StatefulWidget {
  final Company company;
  final Color color;

  const CompanyInfoWidget(
      {Key? key, required this.company, required this.color})
      : super(key: key);

  @override
  _CompanyInfoWidgetState createState() =>
      _CompanyInfoWidgetState();
}

class _CompanyInfoWidgetState extends State<CompanyInfoWidget> {
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

    if(widget.company.description != null || widget.company.parent != null || widget.company.websites != null || widget.company.url != null
    )
      return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                                widget.company.description != null
                                    ? '${widget.company.description}'
                                    : 'N/A',
                                style:
                                    TextStyle(color: adjustedIconColorContent),
                              )),
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
                                    Icons.business_rounded,
                                    color: adjustedIconColor,
                                  ),
                                  header: Text(
                                    'Parent Company',
                                    style: TextStyle(color: adjustedIconColor),
                                  ),
                                  content: Center(
                                      child: Column(
                                    children: [
                                      if (widget.company.parent !=
                                          null)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              color: widget.color,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Text(
                                                    'Parent Company',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: adjustedIconColor,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child:  CompanyCard(
                                                          company:
                                                              widget.company.parent, size: 80,)
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                    ],
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
                                      if (widget.company.websites != null)
                                        CompanyWebsiteList(
                                          websites: widget.company.websites!,
                                          lightColor: widget.color,
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
    return Container();
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
    if (widget.company.description != null) values.add(0);
    if (widget.company.parent != null) values.add(1);
    if (widget.company.websites != null || widget.company.url != null) values.add(2);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}

class CompanyGamesContainerSwitchWidget extends StatefulWidget {
  final Company company;
  final Color color;

  const CompanyGamesContainerSwitchWidget(
      {Key? key, required this.company, required this.color})
      : super(key: key);

  @override
  _CompanyGamesContainerSwitchWidgetState createState() =>
      _CompanyGamesContainerSwitchWidgetState();
}

class _CompanyGamesContainerSwitchWidgetState
    extends State<CompanyGamesContainerSwitchWidget> {
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

    if(widget.company.developed != null || widget.company.published != null)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
              padding: EdgeInsets.only(top: mediaQueryHeight * .058),
              child: SizedBox(
                  child: _selectedIndex == 0
                      ? GameListView(
                          color: headerBorderColor,
                          headline: 'Developed',
                          games: widget.company.developed!,
                          // Eine leere Liste übergeben, wenn parentGame null ist
                          isPagination: false,
                          body: '',
                          showLimit: 5,
                        )
                      : GameListView(
                              color: headerBorderColor,
                              headline: 'Published',
                              games: widget.company.published!,
                              isPagination: false,
                              body: '',
                              showLimit: 5,
                            )
                         ),
            )
          ],
        ),
      ),
    );
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
    if (widget.company.developed != null) values.add(0);
    if (widget.company.published != null) values.add(1);

    if (values.isNotEmpty) {
      values.sort();
      _selectedIndex = values.first;
    }
  }
}
