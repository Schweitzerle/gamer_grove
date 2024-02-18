import 'dart:math';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/website.dart';
import 'package:gamer_grove/model/widgets/RatingWidget.dart';
import 'package:gamer_grove/model/widgets/bannerImage.dart';
import 'package:gamer_grove/model/widgets/characterListPreview.dart';
import 'package:gamer_grove/model/widgets/character_view.dart';
import 'package:gamer_grove/model/widgets/characters_view.dart';
import 'package:gamer_grove/model/widgets/circular_rating_widget.dart';
import 'package:gamer_grove/model/widgets/collection_view.dart';
import 'package:gamer_grove/model/widgets/company_view.dart';
import 'package:gamer_grove/model/widgets/countUpRow.dart';
import 'package:gamer_grove/model/widgets/event_list.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/events_view.dart';
import 'package:gamer_grove/model/widgets/franchise_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/game_engine_view.dart';
import 'package:gamer_grove/model/widgets/imagePreview.dart';
import 'package:gamer_grove/model/widgets/infoRow.dart';
import 'package:gamer_grove/model/widgets/platform_view.dart';
import 'package:gamer_grove/model/widgets/toggleSwitchesGameDetailScreen.dart';
import 'package:gamer_grove/model/widgets/video_list.dart';
import 'package:gamer_grove/model/widgets/video_player_view.dart';
import 'package:gamer_grove/model/widgets/video_view.dart';
import 'package:gamer_grove/model/widgets/website_List.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:motion/motion.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../singleton/sinlgleton.dart';
import 'dart:developer';

import '../widgets/language_support_table.dart';
import '../widgets/gameListPreview.dart';
import 'gameGridView.dart';

class CharacterDetailScreen extends StatefulWidget {
  static Route route(Character character, BuildContext context) {
    return MaterialPageRoute(
      builder: (context) => CharacterDetailScreen(
        character: character,
        context: context,
      ),
    );
  }

  final Character character;
  final BuildContext context;

  CharacterDetailScreen({required this.character, required this.context});

  @override
  _CharacterDetailScreenState createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late Color colorPalette;
  late Color lightColor;
  late Color darkColor;
  late PaletteColor color;
  bool isColorLoaded = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      colorPalette = Theme.of(widget.context).colorScheme.inversePrimary;
      lightColor = Theme.of(widget.context).colorScheme.primary;
      darkColor = Theme.of(widget.context).colorScheme.background;
    });
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([
      getColorPalette(),
    ]);
  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> getColorPalette() async {
    if (widget.character.mugShotID != null &&
        widget.character.mugShotID!.url != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage('${widget.character.mugShotID!.url}'),
        size: Size(100, 150), // Adjust the image size as needed
        maximumColorCount: 10, // Adjust the maximum color count as needed
      );
      setState(() {
        color = paletteGenerator.dominantColor!;
        colorPalette = paletteGenerator.dominantColor?.color ??
            Theme.of(widget.context).colorScheme.inversePrimary;
        lightColor = paletteGenerator.lightVibrantColor?.color ??
            Theme.of(widget.context).colorScheme.primary;
        darkColor = paletteGenerator.darkVibrantColor?.color ??
            Theme.of(widget.context).colorScheme.background;
        isColorLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final coverScaleHeight = mediaQueryHeight / 3.2;
    final coverScaleWidth = coverScaleHeight * 0.66;
    final bannerScaleHeight = mediaQueryHeight * 0.3;

    final coverPaddingScaleHeight = bannerScaleHeight - coverScaleHeight / 2;

    final containerBackgroundColor = colorPalette.darken(10);
    final headerBorderColor = colorPalette;
    final contentBackgroundColor = colorPalette.darken(10).withOpacity(.8);

    final luminance = headerBorderColor.computeLuminance();
    final targetLuminance = 0.5;
    final adjustedTextColor =
        luminance > targetLuminance ? Colors.black : Colors.white;

    var rng = Random();
    int rndGame = rng.nextInt(widget.character.gameIDs!.length);

    //TODO: Banner nicht scrollable machen
    return Scaffold(
      body: Container(
        height: mediaQueryHeight,
        width: mediaQueryWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.0, 0.9), // Start at the middle left
            end: Alignment(0.0, 0.4), // End a little above the middle
            colors: [
              colorPalette.darken(20),
              colorPalette.lighten(10),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  // Artwork image
                  BannerImageWidget(
                    game: widget.character.gameIDs![rndGame],
                    color: containerBackgroundColor,
                  ),
                  // Cover image
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, right: 16, top: coverPaddingScaleHeight),
                    child: Row(
                      children: [
                        // Cover image
                        Motion(
                          glare: GlareConfiguration(
                            color: colorPalette.lighten(20),
                            minOpacity: 0,
                          ),
                          shadow: const ShadowConfiguration(
                              color: Colors.black, blurRadius: 2, opacity: .2),
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            height: coverScaleHeight,
                            width: coverScaleWidth,
                            child: CharacterView(
                              character: widget.character,
                              buildContext: context,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        // Additional Info Rows
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              widget.character.species != null
                                  ? InfoRow.buildInfoRow(
                                      FontAwesomeIcons.redditAlien,
                                      widget.character.species,
                                      containerBackgroundColor,
                                      Color(0xffff6961),
                                      false,
                                      context)
                                  : Container(),
                              widget.character.countryName != null
                                  ? InfoRow.buildInfoRow(
                                      FontAwesomeIcons.flag,
                                      widget.character.countryName!,
                                      containerBackgroundColor,
                                      Color(0xffffb480),
                                      false,
                                      context)
                                  : Container(),
                              widget.character.gender != null
                                  ? InfoRow.buildInfoRow(
                                      FontAwesomeIcons.transgender,
                                      widget.character.gender,
                                      containerBackgroundColor,
                                      Color(0xff59adf6),
                                      false,
                                      context)
                                  : Container(),
                              widget.character.url != null
                                  ? InfoRow.buildInfoRow(
                                      FontAwesomeIcons.globe,
                                      widget.character.url,
                                      containerBackgroundColor,
                                      Color(0xffc780e8),
                                      true,
                                      context)
                                  : Container()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text above GamePreviewView
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: coverPaddingScaleHeight / 1.5),
                    child: FittedBox(
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            widget.character.name!.isNotEmpty
                                ? widget.character.name!
                                : 'Loading...',
                            speed: Duration(milliseconds: 150),
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 14,
                    ),
                    Accordion(
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
                      sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                      sectionClosingHapticFeedback: SectionHapticFeedback.light,
                      children: [
                        AccordionSection(
                          isOpen: false,
                          contentVerticalPadding: 10,
                          leftIcon: Icon(
                            Icons.list_alt_rounded,
                            color: adjustedTextColor,
                          ),
                          header: Text(
                            'Description',
                            style: TextStyle(color: adjustedTextColor),
                          ),
                          content: Center(
                              child: Text(
                            widget.character.description != null
                                ? '${widget.character.description}'
                                : 'N/A',
                            style: TextStyle(color: adjustedTextColor),
                          )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    if (widget.character.gameIDs != null &&
                        widget.character.gameIDs!.isNotEmpty)
                      GameListView(
                        color: headerBorderColor,
                        headline: 'Featured Games',
                        games: widget.character.gameIDs,
                        isPagination: false,
                        body: '',
                        showLimit: 5,
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
