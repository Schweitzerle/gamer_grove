// ==================================================
// GAME DETAIL WIDGETS - CLEAN VERSION
// ==================================================

// lib/presentation/pages/game_detail/widgets/game_info_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/game.dart';

class GameInfoCard extends StatelessWidget {
  final Game game;

  const GameInfoCard({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: Container(
        // ✅ Keine feste Höhe mehr - dynamisch basierend auf Inhalt
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game Title - mehr Platz da keine Ratings oben
              Text(
                game.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                maxLines: 3, // ✅ Kann jetzt mehr Zeilen haben bei Bedarf
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Game Info Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Release Date
                  if (game.releaseDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Released ${DateFormatter.formatYearOnly(game.releaseDate!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 6),

                  // Developer
                  if (game.developers.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'by ${game.developers.first.company.name}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Genres Section
              if (game.genres.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: game.genres
                        .take(6) // ✅ Kann jetzt mehr Genres zeigen
                        .map((genre) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text(
                          genre.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}