import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/collection.dart';
import '../widgets/gamePreview.dart';
import 'gameGridPaginationView.dart';
import 'gameGridView.dart';

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

    return response;
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
