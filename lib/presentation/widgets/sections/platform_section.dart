// ==================================================
// PLATFORM SECTION
// ==================================================

// lib/presentation/pages/game_detail/widgets/sections/platform_section.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/game/game.dart';
import '../../../../../core/utils/date_formatter.dart';

class PlatformSection extends StatelessWidget {
  final Game game;

  const PlatformSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Platforms
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: game.platforms.length,
            itemBuilder: (context, index) {
              final platform = game.platforms[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  avatar: const Icon(Icons.devices, size: 16),
                  label: Text(platform.name),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            },
          ),
        ),

        // Release Date
        if (game.firstReleaseDate != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Text(
                'Released: ${DateFormatter.formatFullDate(game.firstReleaseDate!)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ],
    );
  }
}