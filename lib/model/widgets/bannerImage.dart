import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/screenshot.dart';
import '../igdb_models/game.dart';
import '../singleton/sinlgleton.dart';

class BannerImageWidget extends StatelessWidget {
  final Game game;

  BannerImageWidget({
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    final bannerScaleHeight = mediaQueryHeight * 0.3;

    var rng = Random();

    print('Artwork: ${game.artworks![rng.nextInt(game.artworks!.length)].url}');
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Stack(
        children: [
          if (game.artworks != null && game.artworks!.isNotEmpty)
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.background,],
                  stops: [0.1, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.darken,
              child: Image.network(
                '${game.artworks![rng.nextInt(game.artworks!.length)].url}',
                width: mediaQueryWidth,
                height: bannerScaleHeight,
                fit: BoxFit.cover,
              ),
            )
          else
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.background,],
                  stops: [0.1, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.darken,
              child: Container(
                width: mediaQueryWidth,
                height: bannerScaleHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Theme.of(context).cardColor.withOpacity(0.9),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
