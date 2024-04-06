import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/website.dart';
import 'package:gamer_grove/model/widgets/bannerImage.dart';
import 'package:gamer_grove/model/widgets/countUpRow.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/infoRow.dart';
import 'package:gamer_grove/model/widgets/ratingDialog.dart';
import 'package:gamer_grove/model/widgets/toggleSwitchesGameDetailScreen.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:intl/intl.dart';
import 'package:motion/motion.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:vitality/vitality.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../widgets/shimmerGameItem.dart';


class GameDetailScreen extends StatefulWidget {
  static Route route(Game game, BuildContext context, Color colorPalette, Color lightColor) {
    return MaterialPageRoute(
      builder: (context) => GameDetailScreen(
        game: game,
        context: context, colorPalette: colorPalette, lightColor: lightColor,

      ),
    );
  }

  final Game game;
  final BuildContext context;
  final Color colorPalette;
  final Color lightColor;

  GameDetailScreen({
    required this.game,
    required this.context, required this.colorPalette, required this.lightColor,
  });

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool isColorLoaded = false;
  final apiService = IGDBApiService();


  @override
  void initState() {
    super.initState();
  }


  Future<List<dynamic>> getIGDBData() async {
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

      return response;
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
    return [];
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

    final containerBackgroundColor = widget.colorPalette.darken(10);
    final headerBorderColor = widget.colorPalette;

    final luminance = headerBorderColor.computeLuminance();
    const targetLuminance = 0.5;
    final adjustedTextColor =
        luminance > targetLuminance ? Colors.black : Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          Vitality.randomly(
            background: Theme.of(context).colorScheme.background.darken(20),
            maxOpacity: 0.8,
            minOpacity: 0.3,
            itemsCount: 80,
            enableXMovements: false,
            whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
            maxSpeed: 0.1,
            maxSize: 30,
            minSpeed: 0.1,
            randomItemsColors: [
              widget.colorPalette,
              widget.colorPalette.darken(10),
              widget.colorPalette.lighten(10),
              widget.colorPalette.darken(5),
              widget.colorPalette.lighten(5),
              widget.colorPalette.darken(20),
              widget.colorPalette.lighten(20),
              widget.colorPalette.onColor,
              Theme.of(context).colorScheme.onPrimary
            ],
            randomItemsBehaviours: [
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: Icons.videogame_asset_outlined),
              ItemBehaviour(shape: ShapeType.Icon, icon: Icons.videogame_asset),
              ItemBehaviour(shape: ShapeType.Icon, icon: Icons.gamepad),
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: Icons.gamepad_outlined),
              ItemBehaviour(
                  shape: ShapeType.Icon,
                  icon: CupertinoIcons.gamecontroller_fill),
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: CupertinoIcons.gamecontroller),
              ItemBehaviour(shape: ShapeType.StrokeCircle),
            ],
          ),
          Container(
          height: mediaQueryHeight,
          width: mediaQueryWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.0, 0.9), // Start at the middle left
              end: Alignment(0.0, 0.7), // End a little above the middle
              colors: [
                widget.colorPalette.lighten(10),
                Colors.transparent,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    if (widget.game.artworks != null)
                      BannerImageWidget(
                        game: widget.game,
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
                              color: widget.colorPalette.lighten(20),
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
                                isClickable: false,
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
                                        context)
                                    : Container(),
                                widget.game.status != null
                                    ? InfoRow.buildInfoRow(
                                        Icons.info_outline_rounded,
                                        widget.game.status,
                                        containerBackgroundColor,
                                        Color(0xfff8f38d),
                                        context)
                                    : Container(),
                                widget.game.category != null
                                    ? InfoRow.buildInfoRow(
                                        Icons.category_outlined,
                                        widget.game.category,
                                        containerBackgroundColor,
                                        Color(0xff42d6a4),
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
                                        widget.lightColor)
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
                                        widget.lightColor)
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
                                        widget.lightColor)
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
                          shadowColor: widget.colorPalette,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  widget.game.name!.isNotEmpty
                                      ? widget.game.name!
                                      : 'Loading...',
                                  speed: Duration(milliseconds: 150),
                                  textStyle: const TextStyle(
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
                FutureBuilder<List<dynamic>>(
                    future: getIGDBData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final response = snapshot.data!;
                        List<Game> games = [];
                        List<Event> events = [];
                        List<Character> characters = [];

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

                        return  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (games.isNotEmpty)
                              SummaryAndStorylineWidget(
                                  game: games[0], color: widget.colorPalette),
                            if (games.isNotEmpty)
                              CollectionsEventsContainerSwitchWidget(
                                game: games[0],
                                color: widget.colorPalette,
                                events: events,
                                characters: characters,
                                adjustedTextColor: adjustedTextColor,
                              ),
                            if (games.isNotEmpty)
                              GamesContainerSwitchWidget(
                                  game: games[0], color: widget.colorPalette),
                            if (games.isNotEmpty)
                              ImagesContainerSwitchWidget(
                                  game: games[0], color: widget.colorPalette),
                            const SizedBox(
                              height: 14,
                            )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      // Display a loading indicator while fetching data
                      return ShimmerItem.buildShimmerGameDetailScreen(context);
                    }),
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
                      barrierColor: widget.colorPalette.darken(30).withOpacity(.8),
                      builder: (BuildContext context) {
                        return CustomRatingDialog(
                          colorPalette: widget.colorPalette,
                          adjustedTextColor: adjustedTextColor,
                          game: widget.game,
                        );
                      });
                },
                child: GlassContainer(
                    height: 60,
                    width: 60,
                    shadowStrength: 4,
                    blur: 12,
                    shape: BoxShape.rectangle,
                    color: widget.colorPalette.darken(40).withOpacity(.1),
                    borderRadius: BorderRadius.circular(14),
                    shadowColor: widget.colorPalette.lighten(20),
                    child: Icon(
                      CupertinoIcons.gamecontroller_fill,
                      color: widget.colorPalette.onColor,
                    )),
              ),
            ),
          ),
      ]
      ),
    );
  }
}
