import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/screenshot.dart';
import '../igdb_models/game.dart';
import '../singleton/sinlgleton.dart';

class BannerImageWidget extends StatelessWidget {
  final Game game;
  final Color color;

  BannerImageWidget({
    required this.game, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    final bannerScaleHeight = mediaQueryHeight * 0.3;

    var rng = Random();
    int rngArtwork = rng.nextInt(game.artworks!.length);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(14),
        bottomRight: Radius.circular(14),
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
                    color,],
                  stops: [0.1, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.darken,
              child:
              CachedNetworkImage(
                height: bannerScaleHeight,
                width:  mediaQueryWidth,
                imageUrl: '${game.artworks![rngArtwork].url}',
                placeholder: (context, url) =>
                    Container(
                      color: color,
                    ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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
