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
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/widgets/RatingWidget.dart';
import 'package:gamer_grove/model/widgets/bannerImage.dart';
import 'package:gamer_grove/model/widgets/characterListPreview.dart';
import 'package:gamer_grove/model/widgets/character_view.dart';
import 'package:gamer_grove/model/widgets/circular_rating_widget.dart';
import 'package:gamer_grove/model/widgets/collection_view.dart';
import 'package:gamer_grove/model/widgets/company_view.dart';
import 'package:gamer_grove/model/widgets/countUpRow.dart';
import 'package:gamer_grove/model/widgets/event_list.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/franchise_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/game_engine_view.dart';
import 'package:gamer_grove/model/widgets/imagePreview.dart';
import 'package:gamer_grove/model/widgets/infoRow.dart';
import 'package:gamer_grove/model/widgets/platform_view.dart';
import 'package:gamer_grove/model/widgets/toggleSwitchGamesContainer.dart';
import 'package:gamer_grove/model/widgets/toggleSwitchImageContainers.dart';
import 'package:gamer_grove/model/widgets/toggleSwitchSummaryStorylineView.dart';
import 'package:gamer_grove/model/widgets/video_list.dart';
import 'package:gamer_grove/model/widgets/video_player_view.dart';
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

class GameDetailScreen extends StatefulWidget {
  static Route route(Game game, BuildContext context) {
    return MaterialPageRoute(
      builder: (context) => GameDetailScreen(
        game: game,
        context: context,
      ),
    );
  }

  final Game game;
  final BuildContext context;

  GameDetailScreen({required this.game, required this.context});

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

  List<String> staggeredText = [
    'Bundles',
    'DlCs',
    'Expanded Games',
    'Expansions',
    'Forks',
    'Ports',
    'Remakes',
    'Remasters',
    'Standalone Expansions'
  ];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    setState(() {
      colorPalette = Theme.of(widget.context).colorScheme.inversePrimary;
      lightColor = Theme.of(widget.context).colorScheme.primary;
      darkColor = Theme.of(widget.context).colorScheme.background;
    });
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
        fields akas, checksum,country_name, created_at, description, games.*, games.cover.*, gender, mug_shot, mug_shot.*, name, slug, species, updated_at, url;
        where games = [${widget.game.id}];
      };
      
       query events "Game Events" {
      fields checksum, created_at, description, end_time, event_logo.*, event_networks.*, games.*, games.cover.*, live_stream_url, name, slug, start_time, time_zone, updated_at, videos.*;
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

    final coverScaleHeight = mediaQueryHeight / 3.2;
    final bannerScaleHeight = mediaQueryHeight * 0.3;

    final coverPaddingScaleHeight = bannerScaleHeight - coverScaleHeight / 2;

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
              colorPalette.lighten(20),
              colorPalette.darken(30),
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
                  if (games.isNotEmpty && games[0].artworks != null)
                    BannerImageWidget(
                      game: games[0],
                      color: color.color,
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
                            color: lightColor,
                            minOpacity: 0,
                          ),
                          shadow: const ShadowConfiguration(
                              color: Colors.black, blurRadius: 2, opacity: .2),
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            height: coverScaleHeight,
                            child: GamePreviewView(
                              game: widget.game,
                              isCover: true,
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
                              widget.game.versionTitle != null
                                  ? InfoRow.buildInfoRow(
                                      Icons.confirmation_num_outlined,
                                      widget.game.versionTitle,
                                      darkColor,
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
                                      darkColor,
                                      Color(0xffffb480),
                                      false,
                                      context)
                                  : Container(),
                              widget.game.status != null
                                  ? InfoRow.buildInfoRow(
                                      Icons.info_outline_rounded,
                                      widget.game.status,
                                      darkColor,
                                      Color(0xfff8f38d),
                                      false,
                                      context)
                                  : Container(),
                              widget.game.category != null
                                  ? InfoRow.buildInfoRow(
                                      Icons.category_outlined,
                                      widget.game.category,
                                      darkColor,
                                      Color(0xff42d6a4),
                                      false,
                                      context)
                                  : Container(),
                              widget.game.url != null
                                  ? InfoRow.buildInfoRow(
                                      LineIcons.globe,
                                      widget.game.url,
                                      darkColor,
                                      Color(0xff08cad1),
                                      true,
                                      context)
                                  : Container(),
                              widget.game.hypes != null
                                  ? CountUpRow.buildCountupRow(
                                      CupertinoIcons.flame,
                                      '',
                                      widget.game.hypes,
                                      Color(0xff59adf6),
                                      '',
                                      darkColor,
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
                                      darkColor,
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
                                      darkColor,
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
                        game: games[0],
                        darkColor: darkColor,
                        lightColor: lightColor),
                  SizedBox(height: 14 ,),
                  if (games.isNotEmpty)
                    GamesContainerSwitchWidget(
                        game: games[0],
                        darkColor: darkColor,
                        lightColor: lightColor),
                  SizedBox(height: 14 ,),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: StaggeredGrid.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 14,
                      children: [
                        if (games.isNotEmpty &&
                            games[0].franchises != null &&
                            games[0].franchises![0].games != null)
                          StaggeredGridTile.count(
                            crossAxisCellCount: 3,
                            mainAxisCellCount: 2,
                            child: FranchiseView(
                              franchise: games[0].franchises![0]!,
                              colorPalette: lightColor,
                            ),
                          ),
                        if (games.isNotEmpty &&
                            games[0].franchises != null &&
                            games[0].franchises![0].games != null)
                          StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                    AllGamesGridScreen.route(
                                        games[0].franchises![0].games!,
                                        context,
                                        games[0].franchises![0].name!));
                              },
                              child: ClayContainer(
                                spread: 2,
                                depth: 60,
                                borderRadius: 14,
                                color: lightColor.withOpacity(.5),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: FittedBox(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Franchise',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(Icons.navigate_next_rounded)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (games.isNotEmpty &&
                            games[0].franchises != null &&
                            games[0].franchises![0].games != null)
                          StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: Container()),
                        if (games.isNotEmpty &&
                            games[0].collection != null &&
                            games[0].collection!.games != null)
                          StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1,
                            child: ClayContainer(
                              depth: 60,
                              spread: 2,
                              customBorderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).cardColor,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      AllGamesGridScreen.route(
                                          games[0].collection!.games!,
                                          context,
                                          games[0].collection!.name!));
                                },
                                child: ClayContainer(
                                  spread: 2,
                                  depth: 60,
                                  borderRadius: 14,
                                  color: lightColor.withOpacity(.5),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: FittedBox(
                                      child: Row(
                                        children: [
                                          Text(
                                            'Collection',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(Icons.navigate_next_rounded)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (games.isNotEmpty &&
                            games[0].collection != null &&
                            games[0].collection!.games != null)
                          StaggeredGridTile.count(
                              crossAxisCellCount: 3,
                              mainAxisCellCount: 2,
                              child: games.isNotEmpty &&
                                      games[0].collection != null &&
                                      games[0].collection!.games != null
                                  ? CollectionView(
                                      collection: games[0].collection!,
                                      colorPalette: lightColor,
                                    )
                                  : Container()),
                        if (games.isNotEmpty &&
                            games[0].collection != null &&
                            games[0].collection!.games != null)
                          StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: Container()),
                      ],
                    ),
                  ),
                  SizedBox(height: 14 ,),
                  if (events.isNotEmpty)
                    EventListView(
                      events: events,
                      headline: 'Events',
                    ),
                  SizedBox(height: 14 ,),
                  if (games.isNotEmpty && games[0].videos != null)
                    VideoListView(
                      videos: games[0].videos,
                      headline: 'Videos',
                      color: color.color,
                      lightColor: lightColor,
                    ),
                  SizedBox(height: 14 ,),
                  if (games.isNotEmpty && games[0].websites != null)
                    WebsiteList(websites: games[0].websites!, lightColor: lightColor,),
                  SizedBox(height: 14 ,),
                  if (games.isNotEmpty && games[0].languageSupports != null)
                    LanguageSupportTable(
                      languageSupports: games[0].languageSupports!,
                      color: lightColor,
                    ),
                  SizedBox(height: 14 ,),
                  if (games.isNotEmpty && games[0].gameEngines != null)
                    GameEngineView(gameEngines: games[0].gameEngines!, lightColor: lightColor,),
                  SizedBox(height: 14 ,),
                  if (games.isNotEmpty && games[0].involvedCompanies != null)
                    InvolvedCompaniesList(
                      involvedCompanies: games[0].involvedCompanies!,
                      lightColor: lightColor,
                    ),
                  SizedBox(height: 14 ,),
                  if (games.isNotEmpty)
                    CharacterListView(
                      character: characters,
                      headline: 'Characters',
                      showLimit: 5,
                      color: lightColor,
                    ),
                  SizedBox(height: 14 ,),
                  if (games.isNotEmpty && games[0].platforms != null)
                    PlatformView(game: games[0], color: lightColor),
                  SizedBox(height: 14 ,),
                  if (games.isNotEmpty)
                    ImagesContainerSwitchWidget(
                        game: games[0],
                        darkColor: darkColor,
                        lightColor: lightColor)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
