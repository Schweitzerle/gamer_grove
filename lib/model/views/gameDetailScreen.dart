import 'dart:math';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/firebase/firebaseUser.dart';
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
import 'package:gamer_grove/model/widgets/ratingDialog.dart';
import 'package:gamer_grove/model/widgets/toggleSwitchesGameDetailScreen.dart';

import 'package:gamer_grove/model/widgets/video_list.dart';
import 'package:gamer_grove/model/widgets/video_player_view.dart';
import 'package:gamer_grove/model/widgets/video_view.dart';
import 'package:gamer_grove/model/widgets/website_List.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
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

class GameDetailScreen extends StatefulWidget {
  static Route route(Game game, BuildContext context, GameModel gameModel) {
    return MaterialPageRoute(
      builder: (context) => GameDetailScreen(
        game: game,
        context: context,
        gameModel: gameModel,
      ),
    );
  }

  final Game game;
  final BuildContext context;
  final GameModel gameModel;

  GameDetailScreen({
    required this.game,
    required this.context,
    required this.gameModel,
  });

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  late Color colorPalette;
  late Color lightColor;
  late Color darkColor;
  late PaletteColor color;
  bool isColorLoaded = false;

  List<Game> games = [];
  List<Character> characters = [];
  List<Event> events = [];

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
    await Future.wait([getColorPalette(), getIGDBData()]);
  }

  Future<void> getIGDBData() async {
    final apiService = IGDBApiService();
    try {
      final body = '''
      query games "Game Details" {
        fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, bundles.cover.*, category, collection.*, collection.games.*, collection.games.cover.*, collections.*, dlcs.*, dlcs.cover.*, expanded_games.*, expanded_games.cover.*, expansions.*, expansions.cover.*, external_games.*, first_release_date, follows, forks.*, forks.cover.*, franchise.*, franchises.*, franchises.games.*, franchises.games.cover.*, game_engines.*, game_engines.logo.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, involved_companies.company.*, involved_companies.company.logo.*, keywords.*, language_supports.*, language_supports.language.*, language_supports.language_support_type.*, multiplayer_modes.*, parent_game.*, parent_game.cover.*, platforms.*, platforms.platform_logo.*, player_perspectives.*, ports.*, ports.cover.*, rating, rating_count, release_dates.*, remakes.*, remakes.cover.*, remasters.*, remasters.cover.*, screenshots.*, similar_games.*, similar_games.cover.*, slug, standalone_expansions.*, standalone_expansions.cover.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_parent.cover.*, version_title, videos.*, websites.*;
        where id = ${widget.game.id};
        limit 1;
      };

      query characters "Game Characters" {
        fields akas, checksum,country_name, created_at, description, games.*, games.cover.*, games.artworks.*, gender, mug_shot, mug_shot.*, name, slug, species, updated_at, url;
        where games = [${widget.game.id}];
      };
      
       query events "Game Events" {
      fields checksum, created_at, description, end_time, event_logo.*, event_networks.*, games.*, games.cover.*, games.artworks.*, live_stream_url, name, slug, start_time, time_zone, updated_at, videos.*;
      where games = [${widget.game.id}];
    };
    ''';

      final List<dynamic> response =
          await apiService.getIGDBData(IGDBAPIEndpointsEnum.multiquery, body);

      setState(() {
        // Extract data for game details
        final gameResponse = response.firstWhere(
            (item) => item['name'] == 'Game Details',
            orElse: () => null);
        if (gameResponse != null) {
          games = apiService.parseResponseToGame(gameResponse['result']);
          if (games[0].websites != null) {
            games[0].websites!.add(Website(id: -1, url: games[0].url!));
          } else {
            games[0].websites = [Website(id: -1, url: games[0].url!)];
          }
        }

        // Extract data for game characters
        final charactersResponse = response.firstWhere(
            (item) => item['name'] == 'Game Characters',
            orElse: () => null);
        if (charactersResponse != null) {
          characters =
              apiService.parseResponseToCharacter(charactersResponse['result']);
        }

        final eventsResponse = response.firstWhere(
            (item) => item['name'] == 'Game Events',
            orElse: () => null);
        if (eventsResponse != null) {
          events = apiService.parseResponseToEvent(eventsResponse['result']);
        }
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> getColorPalette() async {
    if (widget.game.cover!.url != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage('${widget.game.cover!.url}'),
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

    final coverScaleHeight = mediaQueryHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;
    final bannerScaleHeight = mediaQueryHeight * 0.3;

    final coverPaddingScaleHeight = bannerScaleHeight - coverScaleHeight / 2;

    final containerBackgroundColor = colorPalette.darken(10);
    final headerBorderColor = colorPalette;
    final contentBackgroundColor = colorPalette.darken(10).withOpacity(.8);

    final luminance = headerBorderColor.computeLuminance();
    final targetLuminance = 0.5;
    final adjustedTextColor =
        luminance > targetLuminance ? Colors.black : Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          Container(
          height: mediaQueryHeight,
          width: mediaQueryWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.0, 0.9), // Start at the middle left
              end: Alignment(0.0, 0.4), // End a little above the middle
              colors: [
                colorPalette.lighten(10),
                colorPalette.darken(40),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    if (games.isNotEmpty)
                      BannerImageWidget(
                        game: games[0],
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
                              child: GamePreviewView(
                                game: widget.game,
                                isCover: true,
                                buildContext: context,
                                needsRating: true,
                                gameModel: widget.gameModel, isClickable: false,
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
                                widget.game.versionTitle != null
                                    ? InfoRow.buildInfoRow(
                                        Icons.confirmation_num_outlined,
                                        widget.game.versionTitle,
                                        containerBackgroundColor,
                                        Color(0xffff6961),
                                        false,
                                        context)
                                    : Container(),
                                widget.game.firstReleaseDate != null
                                    ? InfoRow.buildInfoRow(
                                        CupertinoIcons.calendar_today,
                                        DateFormat('dd.MM.yyyy').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                widget.game.firstReleaseDate! *
                                                    1000)),
                                        containerBackgroundColor,
                                        Color(0xffffb480),
                                        false,
                                        context)
                                    : Container(),
                                widget.game.status != null
                                    ? InfoRow.buildInfoRow(
                                        Icons.info_outline_rounded,
                                        widget.game.status,
                                        containerBackgroundColor,
                                        Color(0xfff8f38d),
                                        false,
                                        context)
                                    : Container(),
                                widget.game.category != null
                                    ? InfoRow.buildInfoRow(
                                        Icons.category_outlined,
                                        widget.game.category,
                                        containerBackgroundColor,
                                        Color(0xff42d6a4),
                                        false,
                                        context)
                                    : Container(),
                                widget.game.hypes != null
                                    ? CountUpRow.buildCountupRow(
                                        CupertinoIcons.flame,
                                        '',
                                        widget.game.hypes,
                                        Color(0xff59adf6),
                                        '',
                                        containerBackgroundColor,
                                        context,
                                        'Hypes: Number of follows a game gets before release',
                                        lightColor)
                                    : Container(),
                                widget.game.follows != null
                                    ? CountUpRow.buildCountupRow(
                                        CupertinoIcons.bookmark_fill,
                                        '',
                                        widget.game.follows,
                                        Color(0xff9d94ff),
                                        '',
                                        containerBackgroundColor,
                                        context,
                                        'Follow: Number of people following a game',
                                        lightColor)
                                    : Container(),
                                widget.game.totalRatingCount != null
                                    ? CountUpRow.buildCountupRow(
                                        Icons.star,
                                        '',
                                        widget.game.totalRatingCount,
                                        Color(0xffc780e8),
                                        '',
                                        containerBackgroundColor,
                                        context,
                                        'Total Ratings Count: Total number of user and external critic scores',
                                        lightColor)
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: coverPaddingScaleHeight / 1.9),
                      child: FittedBox(
                        child: GlassContainer(
                          blur: 12,
                          shadowStrength: 4,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(14),
                          shadowColor: colorPalette,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  widget.game.name!.isNotEmpty
                                      ? widget.game.name!
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
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mediaQueryHeight * .01,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (games.isNotEmpty)
                      SummaryAndStorylineWidget(
                          game: games[0], color: colorPalette),
                    if (games.isNotEmpty)
                      CollectionsEventsContainerSwitchWidget(
                        game: games[0],
                        color: colorPalette,
                        events: events,
                        characters: characters,
                        adjustedTextColor: adjustedTextColor,
                      ),
                    if (games.isNotEmpty)
                      GamesContainerSwitchWidget(
                          game: games[0], color: colorPalette),
                    if (games.isNotEmpty)
                      ImagesContainerSwitchWidget(
                          game: games[0], color: colorPalette),
                    SizedBox(
                      height: 14,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
          Animate(
            autoPlay: true,
            delay: Duration(seconds: 3),
            effects: [FadeEffect(), ScaleEffect(), SlideEffect(), MoveEffect(begin: Offset(80, 0))],
            child: Positioned(
              bottom: mediaQueryHeight * .08,
              right: mediaQueryWidth * .086,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      barrierColor: colorPalette.darken(30).withOpacity(.8),
                      builder: (BuildContext context) {
                        return CustomRatingDialog(
                          colorPalette: colorPalette,
                          adjustedTextColor: adjustedTextColor,
                          gameModel: widget.gameModel,
                        );
                      });
                },
                child: GlassContainer(
                    height: 60,
                    width: 60,
                    shadowStrength: 4,
                    blur: 12,
                    shape: BoxShape.rectangle,
                    color: colorPalette.darken(40).withOpacity(.1),
                    borderRadius: BorderRadius.circular(14),
                    shadowColor: colorPalette.lighten(20),
                    child: Icon(
                      CupertinoIcons.gamecontroller_fill,
                      color: colorPalette.onColor,
                    )),
              ),
            ),
          ),
      ]
      ),
    );
  }
}
