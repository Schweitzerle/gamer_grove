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
import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/game_mode.dart';
import 'package:gamer_grove/model/igdb_models/genre.dart';
import 'package:gamer_grove/model/igdb_models/platform.dart';
import 'package:gamer_grove/model/igdb_models/player_perspectiverequest_path.dart';
import 'package:gamer_grove/model/igdb_models/theme.dart';
import 'package:gamer_grove/model/views/companyGridPaginationView.dart';
import 'package:gamer_grove/model/views/eventGridPaginationView.dart';
import 'package:gamer_grove/model/widgets/company_filter_widget.dart';
import 'package:gamer_grove/model/widgets/event_filter_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/views/gameGridPaginationView.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:multi_dropdown/models/value_item.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../model/widgets/gameListPreview.dart';
import '../../model/widgets/game_filter_widget.dart';
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
  late GameFilterOptions filterOptions;
  late EventFilterOptions eventFilterOptions;
  late CompanyFilterOptions companyFilterOptions;
  late PagingController<int, Game> _pagingController;
  late PagingController<int, Event> _eventPagingController;
  late PagingController<int, Company> _companyPagingController;
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
    filterOptions = GameFilterOptions(releaseDateValues: SfRangeValues(DateTime(1990), DateTime.now()), selectedSorting: ['total_rating_count desc']);
    eventFilterOptions = EventFilterOptions(
        values: SfRangeValues(DateTime(2017), DateTime.now().add(Duration(days: 365))), selectedSorting: ['start_time desc']);
    companyFilterOptions = CompanyFilterOptions(
        values: SfRangeValues(DateTime(1968), DateTime.now().add(Duration(days: 365))), selectedSorting: ['start_date desc']);
    _searchBarController = FloatingSearchBarController();
    _pagingController = PagingController(firstPageKey: 0);
    _eventPagingController = PagingController(firstPageKey: 0);
    _companyPagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchGamesPage(pageKey);
    });
    _eventPagingController.addPageRequestListener((pageKey) {
      _fetchEventsPage(pageKey);
    });
    _companyPagingController.addPageRequestListener((pageKey) {
      _fetchCompaniesPage(pageKey);
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
    _eventPagingController.dispose();
    _companyPagingController.dispose();
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

  Future<void> _fetchEventsPage(int pageKey) async {
    try {
      final List<Event> events = await _fetchEvents(pageKey);

      final isLastPage = events.isEmpty;

      if (isLastPage) {
        _eventPagingController.appendLastPage(events);
        _searchBarController.show();
      } else {
        final nextPageKey = pageKey + 1;
        _eventPagingController.appendPage(events, nextPageKey);
      }
    } catch (error) {
      _eventPagingController.error = error;
    }
  }

  Future<void> _fetchCompaniesPage(int pageKey) async {
    try {
      final List<Company> companies = await _fetchCompanies(pageKey);

      final isLastPage = companies.isEmpty;

      if (isLastPage) {
        _companyPagingController.appendLastPage(companies);
        _searchBarController.show();
      } else {
        final nextPageKey = pageKey + 1;
        _companyPagingController.appendPage(companies, nextPageKey);
      }
    } catch (error) {
      _companyPagingController.error = error;
    }
  }

  Future<List<Company>> _fetchCompanies(int pageKey) async {
    final apiService = IGDBApiService();
    final offset = pageKey * 20;

    final String startUnix =  '& start_date >= ${dateTimeToUnix(companyFilterOptions.values.start)}';
    final int endUnix = dateTimeToUnix(companyFilterOptions.values.end);

    String queryString = 'name ~ *"${query}"*';
    String sortString = companyFilterOptions.selectedSorting.isNotEmpty ? 's ${companyFilterOptions.selectedSorting.join(', ')};' : '';

    final body =
        'fields *, logo.*; $sortString w ${queryString} & start_date != null ${startUnix} & start_date <= ${endUnix}; o $offset; l 20;';

    print(body);

    final response =
        await apiService.getIGDBData(IGDBAPIEndpointsEnum.companies, body);

    final companies = apiService.parseResponseToCompany(response);

    return companies;
  }

  int dateTimeToUnix(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  Future<List<Event>> _fetchEvents(int pageKey) async {
    final apiService = IGDBApiService();
    final offset = pageKey * 20;

    final int startUnix = dateTimeToUnix(eventFilterOptions.values.start);
    final int endUnix = dateTimeToUnix(eventFilterOptions.values.end);

    String queryString = 'name ~ *"${query}"*';
    String sortString = eventFilterOptions.selectedSorting.isNotEmpty ? 's ${eventFilterOptions.selectedSorting.join(', ')};' : '';

    final body =
        'fields checksum, created_at, description, end_time, event_logo.*, event_networks.*, games.*, games.cover.*, games.artworks.*, live_stream_url, name, slug, start_time, time_zone, updated_at, videos.*; s start_time asc; $sortString w ${queryString} & start_time >= ${startUnix} & start_time <= ${endUnix}; o $offset; l 20;';

    print(body);

    final response =
        await apiService.getIGDBData(IGDBAPIEndpointsEnum.events, body);

    final events = apiService.parseResponseToEvent(response);

    return events;
  }

  Future<List<Game>> _fetchGames(int pageKey) async {
    final apiService = IGDBApiService();
    final offset = pageKey * 20;

    String sortString = filterOptions.selectedSorting.isNotEmpty ? 's ${filterOptions.selectedSorting.join(', ')};' : 's total_rating_count desc;';
    String queryString = 'name ~ *"${query}"*'; // Suchfilter für den Spielnamen

    const dateBorder = 631152000;
    final int startUnix = dateTimeToUnix(filterOptions.releaseDateValues.start) > dateBorder ? dateTimeToUnix(filterOptions.releaseDateValues.start) : -725849940;
    final int endUnix = dateTimeToUnix(filterOptions.releaseDateValues.end);

    print(startUnix);
    queryString += ' & first_release_date >= ${startUnix} & first_release_date <= ${endUnix}';


    if (filterOptions.minHypes > 0) {
      queryString += ' & hypes > ${filterOptions.minHypes}';
    }
    if (filterOptions.minFollows > 0) {
      queryString += ' & follows > ${filterOptions.minFollows}';
    }
    if (filterOptions.minAggregatedRatings > 0) {
      queryString +=
          ' & aggregated_rating_count > ${filterOptions.minAggregatedRatings}';
    }
    if (filterOptions.minTotalRatings > 0) {
      queryString += ' & total_rating_count > ${filterOptions.minTotalRatings}';
    }
    if (filterOptions.minRatings > 0) {
      queryString += ' & rating_count > ${filterOptions.minRatings}';
    }
    if (filterOptions.ratingValues.start > 0 ) {
      queryString += ' & rating > ${filterOptions.ratingValues.start}';
    }
    if (filterOptions.ratingValues.end < 100 ) {
      queryString += ' & rating < ${filterOptions.ratingValues.end}';
    }
    if (filterOptions.aggregatedRatingValues.start > 0 ) {
      queryString += ' & aggregated_rating > ${filterOptions.aggregatedRatingValues.start}';
    }
    if (filterOptions.aggregatedRatingValues.end < 100 ) {
      queryString += ' & aggregated_rating < ${filterOptions.aggregatedRatingValues.end}';
    }
    if (filterOptions.totalRatingValues.start > 0 ) {
      queryString += ' & total_rating > ${filterOptions.totalRatingValues.start}';
    }
    if (filterOptions.totalRatingValues.end < 100 ) {
      queryString += ' & total_rating < ${filterOptions.totalRatingValues.end.toString().toDouble().toInt()}';
    }
    if (filterOptions.selectedCategory != null &&
        filterOptions.selectedCategory!.isNotEmpty) {
      queryString +=
          ' & category = ${filterOptions.selectedCategory!.join(', ')}';
    }
    if (filterOptions.selectedStatus != null &&
        filterOptions.selectedStatus!.isNotEmpty) {
      queryString += ' & status = ${filterOptions.selectedStatus!.join(', ')}';
    }
    if (filterOptions.selectedGameModes != null &&
        filterOptions.selectedGameModes!.isNotEmpty) {
      queryString +=
          ' & game_modes = (${filterOptions.selectedGameModes!.join(', ')})';
    }
    if (filterOptions.selectedThemes != null &&
        filterOptions.selectedThemes!.isNotEmpty) {
      queryString += ' & themes = ${filterOptions.selectedThemes!.join(', ')}';
    }
    if (filterOptions.selectedGenres != null &&
        filterOptions.selectedGenres!.isNotEmpty) {
      queryString += ' & genres = ${filterOptions.selectedGenres!.join(', ')}';
    }
    if (filterOptions.selectedPlatforms != null &&
        filterOptions.selectedPlatforms!.isNotEmpty) {
      queryString +=
          ' & platforms = (${filterOptions.selectedPlatforms!.join(', ')})';
    }
    if (filterOptions.selectedPlayerPerspectives != null &&
        filterOptions.selectedPlayerPerspectives!.isNotEmpty) {
      queryString +=
          ' & player_perspectives = (${filterOptions.selectedPlayerPerspectives!.join(', ')})';
    }
    if (filterOptions.selectedAgeRating != null &&
        filterOptions.selectedAgeRating!.isNotEmpty) {
      queryString +=
          ' & age_ratings.rating = ${filterOptions.selectedAgeRating!.join(', ')}';
    }
    // Aufbau des Query-Strings
    final body =
        'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; $sortString where ${queryString}; o $offset; l 20;';

    print(body);

    final response =
        await apiService.getIGDBData(IGDBAPIEndpointsEnum.games, body);

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
        _selectedIndex == 0
            ? GameGridPaginationView(
                pagingController: _pagingController,
                scrollController: _scrollController,
              )
            : _selectedIndex == 1
                ? EventGridPaginationView(
                    pagingController: _eventPagingController,
                    scrollController: _scrollController)
                : CompanyGridPaginationView(
                    pagingController: _companyPagingController,
                    scrollController: _scrollController),
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
              _selectedIndex == 0
                  ? _pagingController.refresh()
                  : _selectedIndex == 1
                      ? _eventPagingController.refresh()
                      : _companyPagingController.refresh();
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
          onQueryChanged: (value) {
            query = value;
          },
          // Specify a custom transition to be used for
          // animating between opened and closed stated.
          transition: CircularFloatingSearchBarTransition(),
          actions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _selectedIndex == 0
                        ? _pagingController.refresh()
                        : _selectedIndex == 1
                            ? _eventPagingController.refresh()
                            : _companyPagingController.refresh();
                    _fetchGamesPage(0);
                  }),
            ),
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            ),
          ],
          clearQueryOnClose: false,
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
                        child: AnimatedToggleSwitch<int>.size(
                          textDirection: TextDirection.ltr,
                          current: _selectedIndex,
                          values: [0, 1, 2],
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
                                  themes: themes,
                                  searchBarController: _searchBarController,
                                  pagingController: _pagingController,
                                  filterOptions: filterOptions,
                                )
                              : _selectedIndex == 1
                                  ? EventFilterScreen(
                                      searchBarController: _searchBarController,
                                      pagingController: _eventPagingController,
                                      filterOptions: eventFilterOptions)
                                  : CompanyFilterScreen(
                                      searchBarController: _searchBarController,
                                      pagingController:
                                          _companyPagingController,
                                      filterOptions: companyFilterOptions)),
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
