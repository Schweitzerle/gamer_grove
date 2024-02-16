import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gamer_grove/model/igdb_models/game_engine.dart';

class GameEngineView extends StatelessWidget {
  final List<GameEngine> gameEngines;
  final Color lightColor;

  const GameEngineView({Key? key, required this.gameEngines, required this.lightColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final luminance = lightColor.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
    luminance > targetLuminance ? Colors.black : Colors.white;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: lightColor.withOpacity(.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8, left: 8),
            child: Text(
              'Game Engines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: adjustedIconColor
              ),
            ),
          ),
          SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: gameEngines.map((engine) {
                return EngineCard(engine: engine);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class EngineCard extends StatelessWidget {
  final GameEngine? engine;

  EngineCard({required this.engine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.black,),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Bild des Unternehmens mit ShaderMask
              if (engine?.logo != null)
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7), // Dunkelheit des Gradients anpassen
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.darken,
                  child: CachedNetworkImage(
                    imageUrl: engine!.logo!.url!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain, // Bildgröße anpassen
                  ),
                ),
              // Name des Unternehmens
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: FittedBox(
                    child: Text(
                      engine?.name ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
