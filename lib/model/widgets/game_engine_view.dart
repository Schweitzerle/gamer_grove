import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gamer_grove/model/igdb_models/game_engine.dart';

class GameEngineView extends StatelessWidget {
  final List<GameEngine> gameEngines;

  const GameEngineView({Key? key, required this.gameEngines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: gameEngines.map((engine) {
          return _buildGameEngineItem(engine, context);
        }).toList(),
      ),
    );
  }

  Widget _buildGameEngineItem(GameEngine engine, BuildContext context) {
    final mediaQueryHeight = MediaQuery
        .of(context)
        .size
        .height;
    final mediaQueryWidth = MediaQuery
        .of(context)
        .size
        .width;
    return ClayContainer(
      width: mediaQueryWidth * .4,
      depth: 60,
      spread: 2,
      borderRadius: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: engine.logo?.url ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[300]),
          errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
        ),
      ),
    );
  }
}
