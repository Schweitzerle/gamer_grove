import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';

class GameGridPaginationView extends StatefulWidget {
  final PagingController<int, Game> pagingController;
  final ScrollController scrollController;

  GameGridPaginationView({
    required this.pagingController, required this.scrollController,
  });

  @override
  State<StatefulWidget> createState() => GameGridPaginationViewState();
}

class GameGridPaginationViewState extends State<GameGridPaginationView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: PagedGridView<int, Game>(
            scrollController: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: .7,
              crossAxisCount: 2,
            ),
            pagingController: widget.pagingController,
            builderDelegate: PagedChildBuilderDelegate<Game>(
              firstPageProgressIndicatorBuilder:(_) => const Padding(
                padding: EdgeInsets.all(78.0),
                child: Center(
                  child: LoadingIndicator(
                      indicatorType: Indicator.pacman, /// Required, The loading type of the widget
                  ),
                ),
              ),
              newPageProgressIndicatorBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: LoadingIndicator(
                    indicatorType: Indicator.pacman, /// Required, The loading type of the widget
                  ),
                ),
              ),
              itemBuilder: (context, game, index) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: GamePreviewView(
                      game: game,
                      isCover: false, buildContext: context,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class AllGamesGridPaginationScreen extends StatefulWidget {
  static Route route(String appBarText, String body) {
    return MaterialPageRoute(
      builder: (context) =>
          AllGamesGridPaginationScreen(appBarText: appBarText, body: body),
    );
  }

  final String appBarText;
  final String body;

  AllGamesGridPaginationScreen({required this.appBarText, required this.body});

  @override
  _AllGamesGridPaginationScreenState createState() =>
      _AllGamesGridPaginationScreenState();
}

class _AllGamesGridPaginationScreenState
    extends State<AllGamesGridPaginationScreen> {
  late ScrollController _scrollController;
  late PagingController<int, Game> _pagingController;
  String query = "";

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pagingController =
        PagingController(firstPageKey: 0); // Change firstPageKey to 0
    _pagingController.addPageRequestListener((pageKey) {
      _fetchGamesPage(pageKey);
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
    final response = await apiService.getIGDBData(
        IGDBAPIEndpointsEnum.games, '${widget.body} o $offset;');

    final games = apiService.parseResponseToGame(response);
    return games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarText),
      ),
      body: GameGridPaginationView(
        pagingController: _pagingController,
        scrollController: _scrollController,
      ),
    );
  }
}
