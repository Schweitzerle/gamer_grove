import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';

class GameGridView extends StatelessWidget {
  final List<Game> collectionGames;

  GameGridView({
    required this.collectionGames,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: .7,
          crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final game = collectionGames[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: GamePreviewView(game: game, isCover: true, buildContext: context)),
          );
        },
        childCount: collectionGames.length,
      ),
    );
  }
}

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
        title: FittedBox(child: Text(appBarText)),
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
