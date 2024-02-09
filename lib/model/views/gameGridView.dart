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
          crossAxisSpacing: 8,
          mainAxisSpacing: 8
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
