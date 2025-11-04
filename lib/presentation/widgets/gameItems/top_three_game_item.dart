import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';

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
    final theme = Theme.of(context);
    final rankingColor = ColorScales.getRankingColor(index);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
      child: GestureDetector(
        onTap: () => Navigations.navigateToGameDetail(game.id, context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Card with ranking badge overlay
            Expanded(
              child: Stack(
                children: [
                  // Game Cover
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: game.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  ImageUtils.getMediumImageUrl(game.coverUrl),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: Icon(
                                    Icons.games,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 32,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: Icon(
                                    Icons.games,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 32,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Icon(
                                  Icons.games,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 32,
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Ranking Badge with shadow
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: rankingColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: rankingColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Game name
            Text(
              game.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
