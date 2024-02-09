import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/views/gameGridPaginationView.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
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
  TextEditingController _searchController = TextEditingController();
  late PagingController<int, Game> _pagingController;
  late FloatingSearchBarController _searchBarController;
  late ScrollController _scrollController;
  String query = "";

  @override
  void initState() {
    super.initState();
    _searchBarController = FloatingSearchBarController();
    _pagingController =
        PagingController(firstPageKey: 0); // Change firstPageKey to 0
    _pagingController.addPageRequestListener((pageKey) {
      _fetchGamesPage(pageKey);
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if ( _scrollController.position.userScrollDirection == ScrollDirection.forward) {
            _searchBarController.show();
        } else if ( _scrollController.position.userScrollDirection == ScrollDirection.reverse) {
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

  Future<void> _fetchGamesPage(int pageKey) async {
    try {
      final List<Game> games = await _fetchGames(pageKey);

      final isLastPage = games.isEmpty;

      if (isLastPage) {
        _pagingController.appendLastPage(games);
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
    final body =
        'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s total_rating_count desc; where name ~ *"${query}"*; o $offset; l 20;';

    final response =
        await apiService.getIGDBData(IGDBAPIEndpointsEnum.games, body);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(children: [
        //TODO: Padding so dass ergebnisse beim anfang gut angezeigt werden aber danach bis nach ganz oben durchscrollen
        GameGridPaginationView(
          pagingController: _pagingController, scrollController: _scrollController,
        ),
        FloatingSearchBar(
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          shadowColor: Theme.of(context).shadowColor,
          iconColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          accentColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          backdropColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          controller: _searchBarController,
          hint: 'Search...',
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
          clearQueryOnClose: false,
          builder: (context, transition) {
            return Container();
          },
        )
      ]),
    );
  }
}
