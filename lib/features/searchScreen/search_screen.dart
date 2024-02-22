import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:bottom_bar_matu/utils/app_utils.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/igdb_models/age_rating.dart';
import 'package:gamer_grove/model/igdb_models/game_mode.dart';
import 'package:gamer_grove/model/igdb_models/genre.dart';
import 'package:gamer_grove/model/igdb_models/platform.dart';
import 'package:gamer_grove/model/igdb_models/player_perspectiverequest_path.dart';
import 'package:gamer_grove/model/igdb_models/theme.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/views/gameGridPaginationView.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:multi_dropdown/models/value_item.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../model/widgets/gameListPreview.dart';
import '../../repository/igdb/IGDBApiService.dart';

class GameSearchScreen extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => GameSearchScreen(),
    );
  }

  @override
  _GameSearchScreenState createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends State<GameSearchScreen> {
  GameFilterOptions filterOptions = GameFilterOptions();
  TextEditingController _searchController = TextEditingController();
  late PagingController<int, Game> _pagingController;
  late FloatingSearchBarController _searchBarController;
  late ScrollController _scrollController;
  String query = "";
  late int _selectedIndex = 0;
  Map<String, String> selectedIndexString = {
    'Games': 'games',
    'Events': 'events',
    'Companies': 'companies',
    'Game Engines': 'game engines'
  };
  List<Genre> genres = [];
  List<GameMode> gameModes = [];
  List<PlatformIGDB> platforms = [];
  List<PlayerPerspective> playerPerspectives = [];
  List<ThemeIDGB> themes = [];

  @override
  void initState() {
    super.initState();
    Future.wait([getIGDBFilterData()]);
    _searchBarController = FloatingSearchBarController();
    _pagingController =
        PagingController(firstPageKey: 0); // Change firstPageKey to 0
    _pagingController.addPageRequestListener((pageKey) {
      _fetchGamesPage(pageKey);
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          _searchBarController.show();
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _searchBarController.hide();
        }
      }
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> getIGDBFilterData() async {
    final apiService = IGDBApiService();
    try {
      const body = '''
       query genres "All Genres" {
        fields *; l 500;
      };
       query game_modes "All Game Modes" {
        fields *; l 500;
      };
     query platforms "All Platforms" {
        fields *; l 500;
      };
       query player_perspectives "All Player Perspectives" {
        fields *; l 500;
      };
      query themes "All Themes" {
        fields *; l 500;
      };
    ''';

      final List<dynamic> response =
          await apiService.getIGDBData(IGDBAPIEndpointsEnum.multiquery, body);

      setState(() {
        // Extract data for game details
        final genreResponse = response.firstWhere(
            (item) => item['name'] == 'All Genres',
            orElse: () => null);
        if (genreResponse != null) {
          genres = apiService.parseResponseToGenres(genreResponse['result']);
        }

        // Extract data for game characters
        final gameModesResponse = response.firstWhere(
            (item) => item['name'] == 'All Game Modes',
            orElse: () => null);
        if (gameModesResponse != null) {
          gameModes =
              apiService.parseResponseToGameModes(gameModesResponse['result']);
        }

        final platformsResponse = response.firstWhere(
            (item) => item['name'] == 'All Platforms',
            orElse: () => null);
        if (platformsResponse != null) {
          platforms =
              apiService.parseResponseToPlatforms(platformsResponse['result']);
        }

        final playerPerspectiveResponse = response.firstWhere(
            (item) => item['name'] == 'All Player Perspectives',
            orElse: () => null);
        if (playerPerspectiveResponse != null) {
          playerPerspectives = apiService.parseResponseToPlayerPerspectives(
              playerPerspectiveResponse['result']);
        }

        final themeResponse = response.firstWhere(
            (item) => item['name'] == 'All Themes',
            orElse: () => null);
        if (themeResponse != null) {
          themes = apiService.parseResponseToThemes(themeResponse['result']);
        }
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<void> _fetchGamesPage(int pageKey) async {
    try {
      final List<Game> games = await _fetchGames(pageKey);

      final isLastPage = games.isEmpty;

      if (isLastPage) {
        _pagingController.appendLastPage(games);
        _searchBarController.show();
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(games, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<List<Game>> _fetchGames(int pageKey) async {
    final apiService = IGDBApiService();
    final offset = pageKey * 20;

    // Erstellen des Query-Strings basierend auf den Filteroptionen
    String queryString = 'name ~ *"${query}"*'; // Suchfilter für den Spielnamen

    // Hinzufügen von Filterausdrücken für nicht-null Filteroptionen
    if (filterOptions.minHypes > 0) {
      queryString += ' & hypes > ${filterOptions.minHypes}';
    }
    if (filterOptions.minFollows > 0) {
      queryString += ' & follows > ${filterOptions.minFollows}';
    }
    if (filterOptions.minAggregatedRatings > 0) {
      queryString += ' & aggregated_rating_count > ${filterOptions.minAggregatedRatings}';
    }
    if (filterOptions.minTotalRatings > 0) {
      queryString += ' & total_rating_count > ${filterOptions.minTotalRatings}';
    }
    if (filterOptions.minRatings > 0) {
      queryString += ' & rating_count > ${filterOptions.minRatings}';
    }
    if (filterOptions.selectedCategory != null && filterOptions.selectedCategory!.isNotEmpty) {
      queryString += ' & category = ${filterOptions.selectedCategory!.join(', ')}';
    }
    if (filterOptions.selectedStatus != null && filterOptions.selectedStatus!.isNotEmpty) {
      queryString += ' & status = [${filterOptions.selectedStatus!.join(', ')}]';
    }
    if (filterOptions.selectedGameModes != null && filterOptions.selectedGameModes!.isNotEmpty) {
      queryString += ' & game_modes = [${filterOptions.selectedGameModes!.join(', ')}]';
    }
    if (filterOptions.selectedThemes != null && filterOptions.selectedThemes!.isNotEmpty) {
      queryString += ' & themes = [${filterOptions.selectedThemes!.join(', ')}]';
    }
    if (filterOptions.selectedGenres != null && filterOptions.selectedGenres!.isNotEmpty) {
      queryString += ' & genres = [${filterOptions.selectedGenres!.join(', ')}]';
    }
    if (filterOptions.selectedPlatforms != null && filterOptions.selectedPlatforms!.isNotEmpty) {
      queryString += ' & platforms = [${filterOptions.selectedPlatforms!.join(', ')}]';
    }
    if (filterOptions.selectedPlayerPerspectives != null && filterOptions.selectedPlayerPerspectives!.isNotEmpty) {
      queryString += ' & player_perspectives = [${filterOptions.selectedPlayerPerspectives!.join(', ')}]';
    }
    if (filterOptions.selectedAgeRating != null && filterOptions.selectedAgeRating!.isNotEmpty) {
      queryString += ' & age_ratings = [${filterOptions.selectedAgeRating!.join(', ')}]';
    }
    // Aufbau des Query-Strings
    final body =
        'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s total_rating_count desc; where ${queryString}; o $offset; l 20;';

    print(body);

    final response = await apiService.getIGDBData(IGDBAPIEndpointsEnum.games, body);

    final games = apiService.parseResponseToGame(response);

    return games;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    Color color = Theme.of(context).colorScheme.tertiaryContainer;
    Color lightColor = Theme.of(context).colorScheme.tertiaryContainer;

    return Scaffold(
      body: Stack(children: [
        //TODO: Padding so dass ergebnisse beim anfang gut angezeigt werden aber danach bis nach ganz oben durchscrollen
        GameGridPaginationView(
          pagingController: _pagingController,
          scrollController: _scrollController,
        ),
        FloatingSearchBar(
          showAfter: Duration(seconds: 3),
          showCursor: true,
          elevation: 20,
          borderRadius: BorderRadius.circular(14),
          border: BorderSide(color: Theme.of(context).colorScheme.background),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          shadowColor: Theme.of(context).shadowColor,
          iconColor:
              Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          accentColor:
              Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          backdropColor:
              Theme.of(context).colorScheme.background.withOpacity(.7),
          controller: _searchBarController,
          hint:
              'Search for ${selectedIndexString.keys.toList()[_selectedIndex]}',
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                query = value;
              });
              _pagingController.refresh();
              _searchBarController.close();
              _searchBarController.hide();
            }
          },
          scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
          transitionDuration: const Duration(milliseconds: 800),
          transitionCurve: Curves.easeInOut,
          physics: const BouncingScrollPhysics(),
          axisAlignment: true ? 0.0 : -1.0,
          openAxisAlignment: 0.0,
          width: true ? 600 : 500,
          debounceDelay: const Duration(milliseconds: 500),
          onQueryChanged: (query) {
            // Call your model, bloc, controller here.
          },
          // Specify a custom transition to be used for
          // animating between opened and closed stated.
          transition: CircularFloatingSearchBarTransition(),
          leadingActions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _pagingController.refresh();
                    _fetchGamesPage(0);
                  }),
            ),
          ],
          actions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _pagingController.refresh();
                    _fetchGamesPage(0);
                  }),
            ),
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            ),
          ],
          clearQueryOnClose: true,
          builder: (context, transition) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClayContainer(
                spread: 2,
                depth: 60,
                borderRadius: 14,
                color: color,
                parentColor: Theme.of(context).colorScheme.onTertiaryContainer,
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
                          values: [0, 1, 2, 3],
                          iconOpacity: 0.2,
                          indicatorSize: const Size.fromWidth(100),
                          iconBuilder: iconBuilder,
                          borderWidth: 4.0,
                          iconAnimationType: AnimationType.onHover,
                          style: ToggleStyle(
                            backgroundColor: color,
                            borderColor: color,
                            borderRadius: BorderRadius.circular(14.0),
                            boxShadow: [
                              BoxShadow(
                                color: color,
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
                      padding: EdgeInsets.only(top: mediaQueryHeight * .064),
                      child: SizedBox(
                          child: _selectedIndex == 0
                              ? GameFilterScreen(
                                  genres: genres,
                                  gameModes: gameModes,
                                  platforms: platforms,
                                  playerPerspectives: playerPerspectives,
                                  themes: themes, searchBarController: _searchBarController, pagingController: _pagingController, filterOptions: filterOptions,
                                )
                              : Container(
                                  color: Colors.pink,
                                )),
                    )
                  ],
                ),
              ),
            );
          },
        )
      ]),
    );
  }

  Widget iconBuilder(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.videogame_asset_outlined;
        break;
      case 1:
        iconData = Icons.event;
        break;
      case 2:
        iconData = Icons.business_rounded;
        break;
      case 3:
        iconData = Icons.build_outlined;
        break;
      default:
        iconData = Icons.videogame_asset_outlined;
    }

    return Icon(
      iconData,
      color: Theme.of(context)
          .colorScheme
          .onTertiaryContainer, // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilder(int value) {
    return ToggleStyle(
      indicatorColor: Theme.of(context).colorScheme.tertiary.withOpacity(.6),
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
}

class GameFilterOptions {
  int minRatings = 0;
  int minTotalRatings = 0;
  int minAggregatedRatings = 0;
  int minFollows = 0;
  int minHypes = 0;
  DateTime? minFirstReleaseDate = DateTime(1990, 01, 01);
  DateTime? maxFirstReleaseDate = DateTime.now().add(Duration(days: 3650));
  List<int?>? selectedAgeRating = [];
  List<int?>? selectedCategory = [];
  List<int?>? selectedGenres = [];
  List<int?>? selectedStatus = [];
  List<int?>? selectedThemes = [];
  List<int?>? selectedGameModes = [];
  List<int?>? selectedPlatforms = [];
  List<int?>? selectedPlayerPerspectives = [];


  // Constructor
  GameFilterOptions({
    this.minRatings = 0,
    this.minTotalRatings = 0,
    this.minAggregatedRatings = 0,
    this.minFollows = 0,
    this.minHypes = 0,
    this.minFirstReleaseDate,
    this.selectedAgeRating,
    this.selectedCategory,
    this.selectedStatus,
    this.selectedGameModes,
    this.selectedThemes,
    this.selectedGenres,
    this.selectedPlatforms,
    this.selectedPlayerPerspectives,
  });
}

class GameFilterScreen extends StatefulWidget {
  final List<Genre> genres;
  final List<GameMode> gameModes;
  final List<PlatformIGDB> platforms;
  final List<PlayerPerspective> playerPerspectives;
  final List<ThemeIDGB> themes;
  final FloatingSearchBarController searchBarController;
  final PagingController pagingController;
  final GameFilterOptions filterOptions;


  const GameFilterScreen(
      {super.key,
      required this.genres,
      required this.gameModes,
      required this.platforms,
      required this.playerPerspectives,
      required this.themes, required this.searchBarController, required this.pagingController, required this.filterOptions});

  @override
  _GameFilterScreenState createState() => _GameFilterScreenState();
}

class _GameFilterScreenState extends State<GameFilterScreen> {

  late int _selectedIndex = 0;
  late int _selectedIndexDropdown = 0;

  @override
  Widget build(BuildContext context) {
    widget.genres.sort((a, b) => a.name!.compareTo(b.name!));
    widget.gameModes.sort((a, b) => a.name!.compareTo(b.name!));
    widget.platforms.sort((a, b) => a.name!.compareTo(b.name!));
    widget.playerPerspectives.sort((a, b) => a.name!.compareTo(b.name!));
    widget.themes.sort((a, b) => a.name!.compareTo(b.name!));

    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    Color color = Theme.of(context).colorScheme.tertiaryContainer;
    Color lightColor = Theme.of(context).colorScheme.tertiaryContainer;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ClayContainer(
            spread: 2,
            depth: 60,
            borderRadius: 14,
            color: color,
            parentColor: Theme.of(context).colorScheme.onTertiaryContainer,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: mediaQueryHeight * .06,
                    child: AnimatedToggleSwitch<int>.size(
                      textDirection: TextDirection.ltr,
                      current: _selectedIndex,
                      values: [0, 1],
                      iconOpacity: 0.2,
                      indicatorSize: const Size.fromWidth(100),
                      iconBuilder: iconBuilder,
                      borderWidth: 4.0,
                      iconAnimationType: AnimationType.onHover,
                      style: ToggleStyle(
                        backgroundColor: color,
                        borderColor: color,
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: [
                          BoxShadow(
                            color: color,
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
                  padding: EdgeInsets.only(top: mediaQueryHeight * .064),
                  child: SizedBox(
                      child: _selectedIndex == 0
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text('Minimum User Ratings'),
                                  SfSlider(
                                    min: 0.0,
                                    max: 100.0,
                                    tooltipShape: SfPaddleTooltipShape(),
                                    value: widget.filterOptions.minRatings.toDouble(),
                                    interval: 20,
                                    showTicks: false,
                                    showLabels: true,
                                    enableTooltip: true,
                                    minorTicksPerInterval: 1,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        widget.filterOptions.minRatings =
                                            value.toInt();
                                      });
                                    },
                                  ),
                                  Text('Minimum Total Ratings'),
                                  SfSlider(
                                    min: 0.0,
                                    max: 100.0,
                                    tooltipShape: SfPaddleTooltipShape(),
                                    value: widget.filterOptions.minTotalRatings
                                        .toDouble(),
                                    interval: 20,
                                    showTicks: false,
                                    showLabels: true,
                                    enableTooltip: true,
                                    minorTicksPerInterval: 1,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        widget.filterOptions.minTotalRatings =
                                            value.toInt();
                                      });
                                    },
                                  ),
                                  Text('Minimum Critics Ratings'),
                                  SfSlider(
                                    min: 0.0,
                                    max: 100.0,
                                    tooltipShape: SfPaddleTooltipShape(),
                                    value: widget.filterOptions.minAggregatedRatings
                                        .toDouble(),
                                    interval: 20,
                                    showTicks: false,
                                    showLabels: true,
                                    enableTooltip: true,
                                    minorTicksPerInterval: 1,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        widget.filterOptions.minAggregatedRatings =
                                            value.toInt();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text('Minimum Follows'),
                                  SfSlider(
                                    min: 0.0,
                                    max: 100.0,
                                    tooltipShape: SfPaddleTooltipShape(),
                                    value: widget.filterOptions.minFollows.toDouble(),
                                    interval: 20,
                                    showTicks: false,
                                    showLabels: true,
                                    enableTooltip: true,
                                    minorTicksPerInterval: 1,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        widget.filterOptions.minFollows =
                                            value.toInt();
                                      });
                                    },
                                  ),
                                  Text('Minimum Hypes'),
                                  SfSlider(
                                    min: 0.0,
                                    max: 100.0,
                                    tooltipShape: SfPaddleTooltipShape(),
                                    value: widget.filterOptions.minHypes.toDouble(),
                                    interval: 20,
                                    showTicks: false,
                                    showLabels: true,
                                    enableTooltip: true,
                                    minorTicksPerInterval: 1,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        widget.filterOptions.minHypes = value.toInt();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )),
                )
              ],
            ),
          ),
          SizedBox(
            height: 14,
          ),
          ClayContainer(
            spread: 2,
            depth: 60,
            borderRadius: 14,
            color: color,
            parentColor: Theme.of(context).colorScheme.onTertiaryContainer,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: mediaQueryHeight * .06,
                    child: AnimatedToggleSwitch<int>.size(
                      textDirection: TextDirection.ltr,
                      current: _selectedIndexDropdown,
                      values: [0, 1],
                      iconOpacity: 0.2,
                      indicatorSize: const Size.fromWidth(100),
                      iconBuilder: iconBuilderDropdown,
                      borderWidth: 4.0,
                      iconAnimationType: AnimationType.onHover,
                      style: ToggleStyle(
                        backgroundColor: color,
                        borderColor: color,
                        borderRadius: BorderRadius.circular(14.0),
                        boxShadow: [
                          BoxShadow(
                            color: color,
                            spreadRadius: 0,
                            blurRadius: 0,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      styleBuilder: styleBuilderDropdown,
                      onChanged: (i) =>
                          setState(() => _selectedIndexDropdown = i),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: mediaQueryHeight * .064),
                  child: SizedBox(
                      child: _selectedIndexDropdown == 0
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: MultiSelectDropDown(
                                        borderRadius:14,
                                        borderWidth: 4,
                                        borderColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                        hint: 'Age Ratings',
                                        onOptionSelected: (options) {
                                          widget.filterOptions.selectedAgeRating = options
                                              .map((item) => item.value)
                                              .toList();
                                        },
                                        onOptionRemoved: (index, item) {
                                          setState(() {
                                            widget.filterOptions.selectedAgeRating!.remove(item.value);
                                          });
                                        },
                                        options:
                                            AgeRatingRating.values.map((rating) {
                                          return ValueItem(
                                            label: rating.value,
                                            value: rating.intValue,
                                          );
                                        }).toList(),
                                        maxItems: AgeRatingRating.values.length,
                                        selectionType: SelectionType.multi,
                                        chipConfig: const ChipConfig(
                                            wrapType: WrapType.wrap),
                                        dropdownHeight: 300,
                                        optionTextStyle:
                                            const TextStyle(fontSize: 16),
                                        selectedOptionIcon:
                                            const Icon(Icons.check_circle),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: MultiSelectDropDown(
                                        borderRadius:14,
                                        borderWidth: 4,
                                        borderColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                        hint: 'Category',
                                        onOptionSelected: (options) {
                                          widget.filterOptions.selectedCategory = options
                                              .map((item) => item.value)
                                              .toList();
                                        },
                                        onOptionRemoved: (index, item) {
                                          setState(() {
                                            widget.filterOptions.selectedCategory!.remove(item.value);
                                          });
                                        },
                                        options:
                                            GameCategoryEnum.values.map((rating) {
                                          return ValueItem(
                                            label: rating.stringValue,
                                            value: rating.value,
                                          );
                                        }).toList(),
                                        maxItems: GameCategoryEnum.values.length,
                                        selectionType: SelectionType.multi,
                                        chipConfig: const ChipConfig(
                                            wrapType: WrapType.wrap),
                                        dropdownHeight: 300,
                                        optionTextStyle:
                                            const TextStyle(fontSize: 16),
                                        selectedOptionIcon:
                                            const Icon(Icons.check_circle),
                                      ),
                                    ),
                                  ),
                                  widget.genres.isNotEmpty
                                      ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                            width:
                                                MediaQuery.of(context).size.width,
                                            child: MultiSelectDropDown(
                                              borderRadius:14,
                                              borderWidth: 4,
                                              borderColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                              hint: 'Genres',
                                              onOptionSelected: (options) {
                                                widget.filterOptions.selectedGenres = options
                                                    .map((item) => item.value)
                                                    .toList();
                                              },
                                              onOptionRemoved: (index, item) {
                                                setState(() {
                                                  widget.filterOptions.selectedGenres
                                                      !.remove(item.value);
                                                });
                                              },
                                              options:
                                                  widget.genres.map((rating) {
                                                return ValueItem(
                                                  label: rating.name!,
                                                  value: rating.id,
                                                );
                                              }).toList(),
                                              maxItems: widget.genres.length,
                                              selectionType: SelectionType.multi,
                                              chipConfig: const ChipConfig(
                                                  wrapType: WrapType.wrap),
                                              dropdownHeight: 300,
                                              optionTextStyle:
                                                  const TextStyle(fontSize: 16),
                                              selectedOptionIcon:
                                                  const Icon(Icons.check_circle),
                                            ),
                                          ),
                                      )
                                      : Container(),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: MultiSelectDropDown(
                                        borderRadius:14,
                                        borderWidth: 4,
                                        borderColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                        hint: 'Status',
                                        onOptionSelected: (options) {
                                          widget.filterOptions.selectedStatus = options
                                              .map((item) => item.value)
                                              .toList();
                                        },
                                        onOptionRemoved: (index, item) {
                                          setState(() {
                                            widget.filterOptions.selectedStatus!.remove(item.value);
                                          });
                                        },
                                        options:
                                            GameStatusEnum.values.map((rating) {
                                          return ValueItem(
                                            label: rating.stringValue,
                                            value: rating.value,
                                          );
                                        }).toList(),
                                        maxItems: GameStatusEnum.values.length,
                                        selectionType: SelectionType.multi,
                                        chipConfig: const ChipConfig(
                                            wrapType: WrapType.wrap),
                                        dropdownHeight: 300,
                                        optionTextStyle:
                                            const TextStyle(fontSize: 16),
                                        selectedOptionIcon:
                                            const Icon(Icons.check_circle),
                                      ),
                                    ),
                                  ),
                                  widget.themes.isNotEmpty
                                      ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                            width:
                                                MediaQuery.of(context).size.width,
                                            child: MultiSelectDropDown(
                                              borderRadius:14,
                                              borderWidth: 4,
                                              borderColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                              hint: 'Themes',
                                              onOptionSelected: (options) {
                                                widget.filterOptions.selectedThemes = options
                                                    .map((item) => item.value)
                                                    .toList();
                                              },
                                              onOptionRemoved: (index, item) {
                                                setState(() {
                                                  widget.filterOptions.selectedThemes!
                                                      .remove(item.value);
                                                });
                                              },
                                              options:
                                                  widget.themes.map((rating) {
                                                return ValueItem(
                                                  label: rating.name!,
                                                  value: rating.id,
                                                );
                                              }).toList(),
                                              maxItems: widget.themes.length,
                                              selectionType: SelectionType.multi,
                                              chipConfig: const ChipConfig(
                                                  wrapType: WrapType.wrap),
                                              dropdownHeight: 300,
                                              optionTextStyle:
                                                  const TextStyle(fontSize: 16),
                                              selectedOptionIcon:
                                                  const Icon(Icons.check_circle),
                                            ),
                                          ),
                                      )
                                      : Container(),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  widget.platforms.isNotEmpty
                                      ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                            width:
                                                MediaQuery.of(context).size.width,
                                            child: MultiSelectDropDown(
                                              borderRadius:14,
                                              borderWidth: 4,
                                              borderColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                              searchEnabled: true,
                                              hint: 'Platforms',
                                              onOptionSelected: (options) {
                                                widget.filterOptions.selectedPlatforms = options
                                                    .map((item) => item.value)
                                                    .toList();
                                              },
                                              onOptionRemoved: (index, item) {
                                                setState(() {
                                                  widget.filterOptions.selectedPlatforms!
                                                      .remove(item.value);
                                                });
                                              },
                                              options:
                                                  widget.platforms.map((rating) {
                                                return ValueItem(
                                                  label: rating.name!,
                                                  value: rating.id,
                                                );
                                              }).toList(),
                                              maxItems: widget.platforms.length,
                                              selectionType: SelectionType.multi,
                                              chipConfig: const ChipConfig(
                                                  wrapType: WrapType.wrap),
                                              dropdownHeight: 300,
                                              optionTextStyle:
                                                  const TextStyle(fontSize: 16),
                                              selectedOptionIcon:
                                                  const Icon(Icons.check_circle),
                                            ),
                                          ),
                                      )
                                      : Container(),
                                  widget.gameModes.isNotEmpty
                                      ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                            width:
                                                MediaQuery.of(context).size.width,
                                            child: MultiSelectDropDown(
                                              borderRadius:14,
                                              borderWidth: 4,
                                              borderColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                              hint: 'Game Modes',
                                              onOptionSelected: (options) {
                                                widget.filterOptions.selectedGameModes = options
                                                    .map((item) => item.value)
                                                    .toList();
                                              },
                                              onOptionRemoved: (index, item) {
                                                setState(() {
                                                  widget.filterOptions.selectedGameModes!
                                                      .remove(item.value);
                                                });
                                              },
                                              options:
                                                  widget.gameModes.map((rating) {
                                                return ValueItem(
                                                  label: rating.name!,
                                                  value: rating.id,
                                                );
                                              }).toList(),
                                              maxItems: widget.gameModes.length,
                                              selectionType: SelectionType.multi,
                                              chipConfig: const ChipConfig(
                                                  wrapType: WrapType.wrap),
                                              dropdownHeight: 300,
                                              optionTextStyle:
                                                  const TextStyle(fontSize: 16),
                                              selectedOptionIcon:
                                                  const Icon(Icons.check_circle),
                                            ),
                                          ),
                                      )
                                      : Container(),
                                  widget.playerPerspectives.isNotEmpty
                                      ? Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                            width:
                                                MediaQuery.of(context).size.width,
                                            child: MultiSelectDropDown(
                                              borderRadius:14,
                                              borderWidth: 4,
                                              borderColor: Theme.of(context).colorScheme.onTertiaryContainer,
                                              hint: 'Player Perspectives',
                                              onOptionSelected: (options) {
                                                widget.filterOptions.selectedPlayerPerspectives =
                                                    options
                                                        .map((item) => item.value)
                                                        .toList();
                                              },
                                              onOptionRemoved: (index, item) {
                                                setState(() {
                                                  widget.filterOptions.selectedPlayerPerspectives!
                                                      .remove(item.value);
                                                });
                                              },
                                              options: widget.playerPerspectives
                                                  .map((rating) {
                                                return ValueItem(
                                                  label: rating.name!,
                                                  value: rating.id,
                                                );
                                              }).toList(),
                                              maxItems: widget
                                                  .playerPerspectives.length,
                                              selectionType: SelectionType.multi,
                                              chipConfig: const ChipConfig(
                                                  wrapType: WrapType.wrap),
                                              dropdownHeight: 300,
                                              optionTextStyle:
                                                  const TextStyle(fontSize: 16),
                                              selectedOptionIcon:
                                                  const Icon(Icons.check_circle),
                                            ),
                                          ),
                                      )
                                      : Container(),
                                ],
                              ),
                            )),
                )
              ],
            ),
          ),
          SizedBox(height: 14,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            ElevatedButton(
              onPressed: () {
                widget.searchBarController.close();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.searchBarController.close();
                widget.pagingController.refresh();
              },
              child: Text('Apply'),
            ),
          ],)
        ],
      ),
    );
  }

  Widget iconBuilder(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.score_outlined;
        break;
      case 1:
        iconData = FontAwesomeIcons.fireFlameCurved;
        break;
      default:
        iconData = Icons.score_outlined;
    }

    return Icon(
      iconData,
      color: Theme.of(context)
          .colorScheme
          .onTertiaryContainer, // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilder(int value) {
    return ToggleStyle(
      indicatorColor: Theme.of(context).colorScheme.tertiary.withOpacity(.6),
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

  Widget iconBuilderDropdown(int index) {
    IconData iconData;
    switch (index) {
      case 0:
        iconData = FontAwesomeIcons.circleInfo;
        break;
      case 1:
        iconData = FontAwesomeIcons.gamepad;
        break;
      default:
        iconData = Icons.score_outlined;
    }

    return Icon(
      iconData,
      color: Theme.of(context)
          .colorScheme
          .onTertiaryContainer, // Adjust colors as needed
    );
  }

  ToggleStyle styleBuilderDropdown(int value) {
    return ToggleStyle(
      indicatorColor: Theme.of(context).colorScheme.tertiary.withOpacity(.6),
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
}
