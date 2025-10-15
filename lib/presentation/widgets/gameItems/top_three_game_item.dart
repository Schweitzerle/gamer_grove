import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/navigations.dart';
import '../../../domain/entities/game/game.dart';

class TopThreeGameItem extends StatelessWidget {
  final Game game;
  final int index;

  const TopThreeGameItem({
    super.key,
    required this.game,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
      child: Column(
        children: [
          // Ranking Badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ColorScales.getRankingColor(index),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Game Card mit Bild
          Expanded(
            child: GestureDetector(
              onTap: () => Navigations.navigateToGameDetail(game.id, context),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: game.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: game.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(Icons.games),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(Icons.games),
                        ),
                      )
                    : Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.games),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Spielname
          Text(
            game.name,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
