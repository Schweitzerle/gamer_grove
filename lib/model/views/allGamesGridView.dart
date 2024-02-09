import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../igdb_models/collection.dart';
import '../widgets/gamePreview.dart';
import 'gameGridPaginationView.dart';
import 'gameGridView.dart';

class AllGamesGridScreen extends StatelessWidget {
  static Route route(List<Game> game, BuildContext context, String appBarText) {
    return MaterialPageRoute(
      builder: (context) => AllGamesGridScreen(
        games: game, appBarText: appBarText,
      ),
    );
  }

  final List<Game> games;
  final String appBarText;

  AllGamesGridScreen({required this.games, required this.appBarText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          GameGridView(collectionGames: games,),
        ],
      ),
    );
  }
}
