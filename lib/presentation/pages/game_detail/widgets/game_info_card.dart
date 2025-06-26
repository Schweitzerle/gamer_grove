// ==================================================
// GAME DETAIL WIDGETS
// ==================================================

// lib/presentation/pages/game_detail/widgets/game_info_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/game.dart';

class GameInfoCard extends StatelessWidget {
  final Game game;
  final VoidCallback? onRatePressed;
  final VoidCallback? onAddToTopThreePressed;

  const GameInfoCard({
    super.key,
    required this.game,
    this.onRatePressed,
    this.onAddToTopThreePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Game Title
              Text(
                game.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),

              if (game.releaseDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Released ${DateFormatter.formatYearOnly(game.releaseDate!)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],

              if (game.developers.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'by ${game.developers.first.company.name}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.paddingMedium),

              // Rating and Stats Row
              Row(
                children: [
                  if (game.rating != null) ...[
                    _buildStatChip(
                      context,
                      icon: Icons.star,
                      label: game.rating!.toStringAsFixed(1),
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                  ],

                  if (game.userRating != null) ...[
                    _buildStatChip(
                      context,
                      icon: Icons.star_border,
                      label: game.userRating!.toStringAsFixed(1),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                  ],

                  if (game.isInTopThree) ...[
                    _buildStatChip(
                      context,
                      icon: Icons.emoji_events,
                      label: 'Top ${game.topThreePosition}',
                      color: Colors.yellow,
                    ),
                    const SizedBox(width: 8),
                  ],

                  const Spacer(),

                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onRatePressed != null)
                        _buildActionButton(
                          context,
                          icon: game.userRating != null ? Icons.star : Icons.star_border,
                          onPressed: onRatePressed!,
                          color: Colors.blue,
                        ),

                      const SizedBox(width: 8),

                      if (onAddToTopThreePressed != null)
                        _buildActionButton(
                          context,
                          icon: game.isInTopThree ? Icons.emoji_events : Icons.emoji_events_outlined,
                          onPressed: onAddToTopThreePressed!,
                          color: Colors.amber,
                        ),
                    ],
                  ),
                ],
              ),

              // Genres (max 3)
              if (game.genres.isNotEmpty) ...[
                const SizedBox(height: AppConstants.paddingMedium),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: game.genres
                      .take(3)
                      .map((genre) => Chip(
                    label: Text(
                      genre.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required VoidCallback onPressed,
        required Color color,
      }) {
    return Material(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}









