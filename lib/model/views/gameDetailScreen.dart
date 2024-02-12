import 'dart:math';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/widgets/RatingWidget.dart';
import 'package:gamer_grove/model/widgets/age_rating_view.dart';
import 'package:gamer_grove/model/widgets/bannerImage.dart';
import 'package:gamer_grove/model/widgets/character_view.dart';
import 'package:gamer_grove/model/widgets/circular_rating_widget.dart';
import 'package:gamer_grove/model/widgets/collection_view.dart';
import 'package:gamer_grove/model/widgets/company_view.dart';
import 'package:gamer_grove/model/widgets/countUpRow.dart';
import 'package:gamer_grove/model/widgets/franchise_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/game_engine_view.dart';
import 'package:gamer_grove/model/widgets/genres.dart';
import 'package:gamer_grove/model/widgets/imagePreview.dart';
import 'package:gamer_grove/model/widgets/infoRow.dart';
import 'package:gamer_grove/model/widgets/pill_button_list.dart';
import 'package:gamer_grove/model/widgets/pill_list.dart';
import 'package:gamer_grove/model/widgets/platform_view.dart';
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
import 'gameListPreview.dart';

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
  Color colorPalette = Singleton.thirdTabColor;
  Color lightColor = Singleton.secondTabColor;
  Color darkColor = Singleton.fourthTabColor;
  bool isColorLoaded = false;

  List<Game> games = [];
  List<Character> characters = [];

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
        fields name, mug_shot.*;
        where games = ${widget.game.id};
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
            begin: Alignment(0.0, 0.4), // Start at the middle left
            end: Alignment(0.0, 0.1), // End a little above the middle
            colors: [
              colorPalette.withOpacity(0.95),
              Theme.of(context).colorScheme.background
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
                  games.isNotEmpty && games[0].artworks != null
                      ? BannerImageWidget(game: games[0])
                      : Container(),
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
                          shadow: ShadowConfiguration(
                              color: darkColor, blurRadius: 2, opacity: .05),
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
                                      Color(0xffc0871f),
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
                                      Color(0xffc9f7f9),
                                      false,
                                      context)
                                  : Container(),
                              widget.game.status != null
                                  ? InfoRow.buildInfoRow(
                                      Icons.info_outline_rounded,
                                      widget.game.status,
                                      darkColor,
                                      Color(0xffa8bb85),
                                      false,
                                      context)
                                  : Container(),
                              widget.game.category != null
                                  ? InfoRow.buildInfoRow(
                                      Icons.category_outlined,
                                      widget.game.category,
                                      darkColor,
                                      Color(0xffe68e6b),
                                      false,
                                      context)
                                  : Container(),
                              widget.game.url != null
                                  ? InfoRow.buildInfoRow(
                                      LineIcons.globe,
                                      widget.game.url,
                                      darkColor,
                                      Color(0xffa8bef7),
                                      true,
                                      context)
                                  : Container(),
                              widget.game.hypes != null
                                  ? CountUpRow.buildCountupRow(
                                      CupertinoIcons.flame,
                                      '',
                                      widget.game.hypes,
                                      Color(0xfffe9c8f),
                                      '',
                                      lightColor,
                                      context,
                                      'Hypes: Number of follows a game gets before release',
                                      darkColor)
                                  : Container(),
                              widget.game.follows != null
                                  ? CountUpRow.buildCountupRow(
                                      CupertinoIcons.bookmark_fill,
                                      '',
                                      widget.game.follows,
                                      Color(0xfffec8c1),
                                      '',
                                      lightColor,
                                      context,
                                      'Follow: Number of people following a game',
                                      darkColor)
                                  : Container(),
                              widget.game.totalRatingCount != null
                                  ? CountUpRow.buildCountupRow(
                                      Icons.star,
                                      '',
                                      widget.game.totalRatingCount,
                                      Color(0xfff9f6c3),
                                      '',
                                      lightColor,
                                      context,
                                      'Total Ratings Count: Total number of user and external critic scores',
                                      darkColor)
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Accordion(
                          headerBorderColor: lightColor,
                          headerBorderWidth: 4,
                          headerBackgroundColor: darkColor,
                          headerBorderColorOpened: Colors.transparent,
                          headerBackgroundColorOpened: lightColor,
                          contentBackgroundColor:
                              Theme.of(context).colorScheme.background,
                          contentBorderColor: lightColor,
                          contentBorderWidth: 4,
                          contentHorizontalPadding: 20,
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
                              contentVerticalPadding: 20,
                              leftIcon: const Icon(
                                Icons.list_alt_rounded,
                              ),
                              header: const Text(
                                'Summary',
                              ),
                              content: Text('${widget.game.summary}'),
                            ),
                          ],
                        ),
                        Accordion(
                          headerBorderColor: lightColor,
                          headerBorderWidth: 4,
                          headerBackgroundColor: darkColor,
                          headerBorderColorOpened: Colors.transparent,
                          headerBackgroundColorOpened: lightColor,
                          contentBackgroundColor:
                              Theme.of(context).colorScheme.background,
                          contentBorderColor: lightColor,
                          contentBorderWidth: 4,
                          contentHorizontalPadding: 20,
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
                              contentVerticalPadding: 20,
                              leftIcon: const Icon(
                                Icons.menu_book_rounded,
                              ),
                              header: const Text(
                                'Storyline',
                              ),
                              content: Text('${widget.game.storyline}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  games.isNotEmpty && games[0].versionParent != null
                      ? Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClayContainer(
                                spread: 2,
                                depth: 60,
                                customBorderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).cardColor,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    'Version Parent Game',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .cardTheme
                                            .surfaceTintColor),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: mediaQueryHeight * .3,
                                width: mediaQueryWidth * .4,
                                child: GamePreviewView(
                                  game: games[0].versionParent!,
                                  isCover: false,
                                  buildContext: context,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  SizedBox(height: 10),
                  games.isNotEmpty && games[0].parentGame != null
                      ? Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClayContainer(
                                spread: 2,
                                depth: 60,
                                customBorderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).cardColor,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    'Parent Game',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .cardTheme
                                            .surfaceTintColor),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: mediaQueryHeight * .3,
                                width: mediaQueryWidth * .4,
                                child: GamePreviewView(
                                  game: games[0].parentGame!,
                                  isCover: false,
                                  buildContext: context,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: StaggeredGrid.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: [
                        StaggeredGridTile.count(
                          crossAxisCellCount: 3,
                          mainAxisCellCount: 2,
                          child: games.isNotEmpty &&
                                  games[0].franchises != null &&
                                  games[0].franchises![0].games != null
                              ? FranchiseView(
                                  franchise: games[0].franchises![0]!,
                                  colorPalette: darkColor,
                                )
                              : Container(),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: ClayContainer(
                            depth: 60,
                            spread: 2,
                            customBorderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardColor,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: FittedBox(
                                  child: Text(
                                    'Coming...',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .cardTheme
                                            .surfaceTintColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: ClayContainer(
                            depth: 60,
                            spread: 2,
                            customBorderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardColor,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: FittedBox(
                                  child: Text(
                                    'Coming...',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .cardTheme
                                            .surfaceTintColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: ClayContainer(
                            depth: 60,
                            spread: 2,
                            customBorderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardColor,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: FittedBox(
                                  child: Text(
                                    'Coming...',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .cardTheme
                                            .surfaceTintColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                            crossAxisCellCount: 3,
                            mainAxisCellCount: 2,
                            child: games.isNotEmpty &&
                                    games[0].collection != null &&
                                    games[0].collection!.games != null
                                ? CollectionView(
                                    collection: games[0].collection!,
                                    colorPalette: darkColor,
                                  )
                                : Container()),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: ClayContainer(
                            depth: 60,
                            spread: 2,
                            customBorderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardColor,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: FittedBox(
                                  child: Text(
                                    'Coming...',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .cardTheme
                                            .surfaceTintColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (games.isNotEmpty && games[0].languageSupports != null)
                    LanguageSupportTable(
                    languageSupports: games[0].languageSupports!, color: lightColor,
                  ),


                  if (games.isNotEmpty && games[0].gameEngines != null)
                    GameEngineView(gameEngines: games[0].gameEngines!),
                  if (games.isNotEmpty && games[0].involvedCompanies != null)
                    InvolvedCompaniesList(
                        involvedCompanies: games[0].involvedCompanies!),
                  if (games.isNotEmpty) CharacterView(character: characters),
                  if (games.isNotEmpty && games[0].platforms != null)
                    PlatformView(platforms: games[0].platforms!),
                  widget.game.aggregatedRating != null &&
                          widget.game.aggregatedRatingCount != null
                      ? RatingWigdet(
                          rating: widget.game.aggregatedRating!,
                          description:
                              'Aggregated Rating based on ${widget.game.aggregatedRatingCount} external critic scores')
                      : Container(),
                  if (widget.game.rating != null &&
                      widget.game.ratingCount != null)
                    RatingWigdet(
                        rating: widget.game.rating!,
                        description:
                            'Average IGDB user rating based on ${widget.game.ratingCount} IGDB user ratings'),
                  if (games.isNotEmpty && games[0].alternativeNames != null)
                    PillList(
                      stringArray: games[0]
                          .alternativeNames!
                          .map((name) => name.name!)
                          .toList(),
                      color: lightColor,
                    ),
                  if (games.isNotEmpty && games[0].gameModes != null)
                    PillButtonList(
                      stringArray: games[0]
                          .gameModes!
                          .map((mode) => mode.name!)
                          .toList(),
                      color: lightColor,
                    ),
                  if (games.isNotEmpty && games[0].genres != null)
                    PillButtonList(
                      stringArray:
                          games[0].genres!.map((genre) => genre.name!).toList(),
                      color: lightColor,
                    ),
                  if (games.isNotEmpty && games[0].keywords != null)
                    PillButtonList(
                      stringArray: games[0]
                          .keywords!
                          .map((keyword) => keyword.name!)
                          .toList(),
                      color: lightColor,
                    ),
                  if (games.isNotEmpty && games[0].playerPerspectives != null)
                    PillButtonList(
                      stringArray: games[0]
                          .playerPerspectives!
                          .map((playerPerspective) => playerPerspective.name!)
                          .toList(),
                      color: lightColor,
                    ),
                  if (games.isNotEmpty && games[0].themes != null)
                    PillButtonList(
                      stringArray:
                          games[0].themes!.map((theme) => theme.name!).toList(),
                      color: lightColor,
                    ),
                  games.isNotEmpty && games[0].ageRatings != null
                      ? AgeRatingListUI(
                          ageRatings: games[0].ageRatings!,
                          color: lightColor,
                        )
                      : Container(),
                  games.isNotEmpty && games[0].bundles != null
                      ? GameListView(
                          headline: 'Bundles',
                          games: games[0].bundles!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].dlcs != null
                      ? GameListView(
                          headline: 'DLCs',
                          games: games[0].dlcs!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].expandedGames != null
                      ? GameListView(
                          headline: 'Expanded Games',
                          games: games[0].expandedGames!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].expansions != null
                      ? GameListView(
                          headline: 'Expansions',
                          games: games[0].expansions!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].forks != null
                      ? GameListView(
                          headline: 'Forks',
                          games: games[0].forks!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].ports != null
                      ? GameListView(
                          headline: 'Ports',
                          games: games[0].ports!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].remakes != null
                      ? GameListView(
                          headline: 'Remakes',
                          games: games[0].remakes!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].remasters != null
                      ? GameListView(
                          headline: 'Remasters',
                          games: games[0].remasters!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].similarGames != null
                      ? GameListView(
                          headline: 'Similar Games',
                          games: games[0].similarGames!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].standaloneExpansions != null
                      ? GameListView(
                          headline: 'Standalone Expansions',
                          games: games[0].standaloneExpansions!,
                          isPagination: false,
                          body: '',
                        )
                      : Container(),
                  games.isNotEmpty && games[0].artworks != null
                      ? ImagePreview(game: games[0], isArtwork: true)
                      : Container(),
                  games.isNotEmpty && games[0].screenshots != null
                      ? ImagePreview(game: games[0], isArtwork: false)
                      : Container()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
