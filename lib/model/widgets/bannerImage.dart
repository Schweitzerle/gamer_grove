import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/screenshot.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
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

    return ClipRRect(
      borderRadius: const BorderRadius.only(
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
                  stops: const [0.1, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.darken,
              child:
              CachedNetworkImage(
                height: bannerScaleHeight,
                width:  mediaQueryWidth,
                imageUrl: '${game.artworks![rng.nextInt(game.artworks!.length)].url}',
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
              child: GlassContainer(
                height: bannerScaleHeight,
                width: mediaQueryWidth,
                blur: 4,
                color: color,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.lighten(20),
                    color.darken(30),
                  ],
                ),
                border: const Border.fromBorderSide(BorderSide.none),
                shadowStrength: 5,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(14),
                shadowColor: color.darken(30),
              ),
            ),
        ],
      ),
    );
  }
}
