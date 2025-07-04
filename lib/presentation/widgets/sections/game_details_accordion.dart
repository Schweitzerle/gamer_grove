// ==================================================
// GAME DETAILS SECTIONS - SEPARATE WIDGETS
// ==================================================

// lib/presentation/pages/game_detail/widgets/sections/game_details_accordion.dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../domain/entities/game/game.dart';
import '../../pages/game_detail/widgets/company_section.dart';
import '../accordion_tile.dart';
import 'external_links_section.dart';
import 'platform_section.dart';
import 'genre_section.dart';
import 'game_features_section.dart';
import 'age_ratings_section.dart';
import 'keywords_section.dart';
import 'statistics_section.dart';

class GameDetailsAccordion extends StatelessWidget {
  final Game game;

  const GameDetailsAccordion({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Column(
            children: [
              // Platforms & Release Info
              if (game.platforms.isNotEmpty)
                AccordionTile(
                  title: 'Platforms & Release',
                  icon: Icons.devices,
                  child: PlatformSection(game: game),
                ),

              // Genres & Categories
              if (game.genres.isNotEmpty || game.themes.isNotEmpty)
                AccordionTile(
                  title: 'Genres & Categories',
                  icon: Icons.category,
                  child: GenreSection(game: game),
                ),

              // External Links & Stores
              if (game.websites.isNotEmpty || game.externalGames.isNotEmpty)
                AccordionTile(
                  title: 'External Links & Stores',
                  icon: Icons.link,
                  child: ExternalLinksSection(game: game),
                ),

              // Game Features
              if (_hasGameFeatures(game))
                AccordionTile(
                  title: 'Game Features',
                  icon: Icons.featured_play_list,
                  child: GameFeaturesSection(game: game),
                ),

              // Age Ratings
              if (game.ageRatings.isNotEmpty)
                AccordionTile(
                  title: 'Age Ratings',
                  icon: Icons.verified_user,
                  child: AgeRatingsSection(ageRatings: game.ageRatings),
                ),

              // Companies
              if (game.involvedCompanies.isNotEmpty)
                AccordionTile(
                  title: 'Companies',
                  icon: Icons.business,
                  child: CompanySection(companies: game.involvedCompanies),
                ),

              // Game Statistics
              AccordionTile(
                title: 'Statistics',
                icon: Icons.analytics,
                child: StatisticsSection(game: game),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasGameFeatures(Game game) {
    return game.gameModes.isNotEmpty ||
        game.playerPerspectives.isNotEmpty ||
        game.hasMultiplayer;
  }
}









