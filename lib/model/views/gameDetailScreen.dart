import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gamer_grove/model/widgets/bannerImage.dart';
import 'package:gamer_grove/model/widgets/countUpRow.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/genres.dart';
import 'package:gamer_grove/model/widgets/imagePreview.dart';
import 'package:gamer_grove/model/widgets/infoRow.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../singleton/sinlgleton.dart';
import 'gameListPreview.dart';

class GameDetailScreen extends StatefulWidget {
  static Route route(Game game) {
    print('GameDetailScreen.route called with game: $game');
    return MaterialPageRoute(
      builder: (context) => GameDetailScreen(game: game),
    );
  }

  final Game game;

  GameDetailScreen({required this.game});

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  Color colorPalette = Singleton.thirdTabColor;
  Color lightColor = Singleton.secondTabColor;
  Color darkColor = Singleton.fourthTabColor;
  bool isColorLoaded = false;

  List<Game> gamesResponse = [];

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
    await Future.wait([getColorPalette(), getIGDBData()]);
  }

  Future<void> getIGDBData() async {
    final apiService = IGDBApiService();
    try {
      final body3 =
          'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, bundles.cover.*, category, collection.*, collections.*, dlcs.*, dlcs.cover.*, expanded_games.*, expanded_games.cover.*, expansions.*, expansions.cover.*, external_games.*, first_release_date, follows, forks.*, forks.cover.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, parent_game.*, parent_game.cover.*, platforms.*, player_perspectives.*, ports.*, ports.cover.*, rating, rating_count, release_dates.*, remakes.*, remakes.cover.*, remasters.*, remasters.cover.*, screenshots.*, similar_games.*, similar_games.cover.*, slug, standalone_expansions.*, standalone_expansions.cover.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_parent.cover.*, version_title, videos.*, websites.*; w id = ${widget.game.id};';

      print('Body: $body3');
      final response =
          await apiService.getIGDBData(IGDBAPIEndpointsEnum.games, body3);

      setState(() {
        gamesResponse = response;
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
        colorPalette =
            paletteGenerator.dominantColor?.color ?? Singleton.thirdTabColor;
        lightColor = paletteGenerator.lightVibrantColor?.color ?? colorPalette;
        darkColor = paletteGenerator.darkVibrantColor?.color ?? colorPalette;
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
                  gamesResponse.isNotEmpty && gamesResponse[0].artworks != null
                      ? BannerImageWidget(game: gamesResponse[0])
                      : Container(),
                  // Cover image
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, right: 16, top: coverPaddingScaleHeight),
                    child: Row(
                      children: [
                        // Cover image
                        Container(
                          height: coverScaleHeight,
                          child: GamePreviewView(
                            game: widget.game,
                            isCover: true,
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
                              widget.game.firstReleaseDate != null ?
                              InfoRow.buildInfoRow(
                                CupertinoIcons.calendar_today,
                                DateFormat('dd.MM.yyyy').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        widget.game.firstReleaseDate! * 1000)),
                                darkColor,
                                Color(0xffc9f7f9),
                                false,
                              ) : Container(),
                              widget.game.status != null ?
                              InfoRow.buildInfoRow(
                                Icons.info_outline_rounded,
                                widget.game.status,
                                darkColor,
                                Color(0xffa8bb85),
                                false,
                              ) :Container(),
                              widget.game.category != null ?
                              InfoRow.buildInfoRow(
                                Icons.category_outlined,
                                widget.game.category,
                                darkColor,
                                Color(0xffe68e6b),
                                false,
                              ) : Container(),
                              widget.game.url != null ?
                              InfoRow.buildInfoRow(
                                LineIcons.globe,
                                widget.game.url,
                                darkColor,
                                Color(0xffa8bef7),
                                true,
                              ) : Container(),
                              widget.game.hypes != null ?
                              CountUpRow.buildCountupRow(
                                CupertinoIcons.flame,
                                '',
                                widget.game.hypes,
                                Color(0xfffe9c8f),
                                '',
                                darkColor,
                              ) :Container(),
                              widget.game.follows != null ?
                              CountUpRow.buildCountupRow(
                                CupertinoIcons.bookmark_fill,
                                '',
                                widget.game.follows,
                                Color(0xfffec8c1),
                                '',
                                darkColor,
                              ) : Container(),
                              widget.game.totalRatingCount != null ?
                              CountUpRow.buildCountupRow(
                                Icons.star,
                                '',
                                widget.game.totalRatingCount,
                                Color(0xfff9f6c3),
                                '',
                                darkColor,
                              ) : Container()
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ExpansionTile(
                          shape: const ContinuousRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          collapsedShape: const ContinuousRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          collapsedBackgroundColor: darkColor.withOpacity(0.95),
                          backgroundColor: lightColor.withOpacity(0.95),
                          childrenPadding: EdgeInsets.all(20),
                          iconColor: Singleton.thirdTabColor,
                          collapsedIconColor: Singleton.firstTabColor,
                          title: Text(
                            'Zusammenfassung',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '${widget.game.summary}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ExpansionTile(
                          shape: const ContinuousRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          collapsedShape: const ContinuousRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          collapsedBackgroundColor: darkColor.withOpacity(0.95),
                          backgroundColor: lightColor.withOpacity(0.95),
                          childrenPadding: EdgeInsets.all(20),
                          iconColor: Singleton.thirdTabColor,
                          collapsedIconColor: Singleton.firstTabColor,
                          title: Text(
                            'Storyline',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '${widget.game.storyline}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  gamesResponse.isNotEmpty &&
                          gamesResponse[0].parentGame != null
                      ? Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClayContainer(
                              spread: 2,
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
                                game: gamesResponse[0].parentGame!,
                                isCover: false,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Container(),
                  gamesResponse.isNotEmpty && gamesResponse[0].bundles != null
                      ? GameListView(
                          headline: 'Bundles',
                          games: gamesResponse[0].bundles!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty && gamesResponse[0].dlcs != null
                      ? GameListView(
                          headline: 'DLCs',
                          games: gamesResponse[0].dlcs!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty &&
                          gamesResponse[0].expandedGames != null
                      ? GameListView(
                          headline: 'Expanded Games',
                          games: gamesResponse[0].expandedGames!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty &&
                          gamesResponse[0].expansions != null
                      ? GameListView(
                          headline: 'Expansions',
                          games: gamesResponse[0].expansions!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty && gamesResponse[0].forks != null
                      ? GameListView(
                          headline: 'Forks',
                          games: gamesResponse[0].forks!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty && gamesResponse[0].ports != null
                      ? GameListView(
                          headline: 'Ports',
                          games: gamesResponse[0].ports!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty && gamesResponse[0].remakes != null
                      ? GameListView(
                          headline: 'Remakes',
                          games: gamesResponse[0].remakes!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty && gamesResponse[0].remasters != null
                      ? GameListView(
                          headline: 'Remasters',
                          games: gamesResponse[0].remasters!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty &&
                          gamesResponse[0].similarGames != null
                      ? GameListView(
                          headline: 'Similar Games',
                          games: gamesResponse[0].similarGames!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty &&
                          gamesResponse[0].standaloneExpansions != null
                      ? GameListView(
                          headline: 'Standalone Expansions',
                          games: gamesResponse[0].standaloneExpansions!,
                        )
                      : Container(),
                  gamesResponse.isNotEmpty &&
                          gamesResponse[0].artworks != null
                      ? ImagePreview(game: gamesResponse[0], isArtwork: true)
                      : Container(),
                  gamesResponse.isNotEmpty &&
                      gamesResponse[0].screenshots != null
                      ? ImagePreview(game: gamesResponse[0], isArtwork: false)
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
