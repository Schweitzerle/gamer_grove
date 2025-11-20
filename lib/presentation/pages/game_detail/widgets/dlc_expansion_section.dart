// ==================================================
// DLC & EXPANSION SECTION
// ==================================================

// lib/presentation/pages/game_detail/widgets/dlc_expansion_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';

class DLCExpansionSection extends StatelessWidget {

  const DLCExpansionSection({
    required this.dlcs, required this.expansions, super.key,
  });
  final List<Game> dlcs;
  final List<Game> expansions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Content',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          if (expansions.isNotEmpty) ...[
            Text(
              'Expansions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            buildHorizontalGameList(expansions),
            const SizedBox(height: AppConstants.paddingMedium),
          ],
          if (dlcs.isNotEmpty) ...[
            Text(
              'DLCs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            buildHorizontalGameList(dlcs),
          ],
        ],
      ),
    );
  }

  Widget buildHorizontalGameList(List<Game> games) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: GameCard(
                game: game,
                onTap: () =>
                    Navigations.navigateToGameDetail(game.id, context),),
          );
        },
      ),
    );
  }
}
