// ==================================================
// SIMPLIFIED GAME DETAILS ACCORDION - Without Callbacks
// ==================================================

// lib/presentation/widgets/sections/game_details_accordion.dart
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../domain/entities/game/game.dart';
import '../../pages/game_detail/widgets/community_info_section.dart';
import '../../pages/game_detail/widgets/company_section.dart';
import '../../pages/game_detail/widgets/game_description_section.dart';
import '../../pages/game_detail/widgets/user_states_section.dart';
import '../accordion_tile.dart';
import 'external_links_section.dart';
import 'game_engines_section.dart';
import 'platform_section.dart';
import 'genre_section.dart';
import 'game_features_section.dart';
import 'age_ratings_section.dart';
import 'keywords_section.dart';
import 'statistics_section.dart';
import 'game_info_section.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ GROUP 1: PERSONAL & COMMUNITY
          _buildAccordionGroup(
            context,
            title: 'Personal & Community',
            icon: Icons.person_outline,
            color: Theme.of(context).colorScheme.primary,
            children: [
              // Your Activity - Always show, no callback needed
              EnhancedAccordionTile(
                title: 'Your Activity',
                icon: Icons.person,
                preview: _buildUserStatesPreview(context, game),
                child: UserStatesContent(game: game), // ✅ Simplified - no callbacks needed
              ),

              // Community & Ratings
              if (_hasCommunityInfo(game))
                EnhancedAccordionTile(
                  title: 'Community & Ratings',
                  icon: Icons.public,
                  preview: _buildCommunityPreview(context, game),
                  child: CommunityInfoContent(game: game),
                ),

              // Game Description
              if (_hasGameDescription(game))
                EnhancedAccordionTile(
                  title: 'About ${game.name}',
                  icon: Icons.description,
                  preview: _buildDescriptionPreview(context, game),
                  child: GameDescriptionContent(game: game),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ✅ GROUP 2: GAME DETAILS
          _buildAccordionGroup(
            context,
            title: 'Game Details',
            icon: Icons.info_outline,
            color: Theme.of(context).colorScheme.secondary,
            children: [
              // Game Information
              if (_hasGameInfo(game))
                EnhancedAccordionTile(
                  title: 'Game Information',
                  icon: Icons.info,
                  preview: _buildGameInfoPreview(context, game),
                  child: GameInfoSection(game: game),
                ),

              // Development Tools
              if (game.gameEngines.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Development Tools',
                  icon: Icons.precision_manufacturing_rounded,
                  preview: _buildEnginesPreview(context, game),
                  child: GameEnginesSection(gameEngines: game.gameEngines),
                ),

              // Platforms & Release
              if (game.platforms.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Platforms & Release',
                  icon: Icons.devices,
                  preview: _buildPlatformsPreview(context, game),
                  child: GenericPlatformSection(
                    game: game,
                    title: 'Available Platforms',
                    showReleaseTimeline: true,
                    showFirstReleaseInfo: true,
                  )
                ),

              // Genres & Categories
              if (game.genres.isNotEmpty || game.themes.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Genres & Categories',
                  icon: Icons.category,
                  preview: _buildGenresPreview(context, game),
                  child: GenreSection(game: game),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ✅ GROUP 3: ADDITIONAL INFORMATION
          _buildAccordionGroup(
            context,
            title: 'Additional Information',
            icon: Icons.more_horiz,
            color: Theme.of(context).colorScheme.tertiary,
            children: [
              // Game Features
              if (_hasGameFeatures(game))
                EnhancedAccordionTile(
                  title: 'Game Features',
                  icon: Icons.featured_play_list,
                  preview: _buildGameFeaturesPreview(context, game),
                  child: GameFeaturesSection(game: game),
                ),

              // Age Ratings
              if (game.ageRatings.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Age Ratings',
                  icon: Icons.verified_user,
                  preview: _buildAgeRatingsPreview(context, game),
                  child: AgeRatingsSection(ageRatings: game.ageRatings),
                ),

              // Companies
              if (game.involvedCompanies.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Companies',
                  icon: Icons.business,
                  preview: _buildCompaniesPreview(context, game),
                  child: GenericCompanySection(
                    involvedCompanies: game.involvedCompanies,
                    title: 'Development & Publishing',
                    showRoles: true,
                  )
                ),

              // External Links & Stores
              if (game.websites.isNotEmpty || game.externalGames.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'External Links & Stores',
                  icon: Icons.link,
                  preview: _buildExternalLinksPreview(context, game),
                  child: ExternalLinksSection(game: game),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ ACCORDION GROUP BUILDER (unchanged)
  Widget _buildAccordionGroup(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required List<Widget> children,
      }) {
    // Filter out any empty children
    final validChildren = children.where((child) => child != const SizedBox.shrink()).toList();

    if (validChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ GROUP HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                // ✅ Section Count Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${validChildren.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ GROUP CONTENT
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Column(
                  children: validChildren,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ HELPER METHODS - Check if sections should be shown (unchanged)
  bool _hasGameInfo(Game game) {
    return game.gameType != null ||
        game.gameStatus != null ||
        (game.versionTitle != null && game.versionTitle!.isNotEmpty) ||
        game.alternativeNames.isNotEmpty ||
        (game.url != null && game.url!.isNotEmpty);
  }

  bool _hasCommunityInfo(Game game) {
    return game.totalRating != null ||
        game.rating != null ||
        game.aggregatedRating != null ||
        (game.hypes != null && game.hypes! > 0) ||
        game.firstReleaseDate != null;
  }

  bool _hasGameDescription(Game game) {
    return (game.summary != null && game.summary!.isNotEmpty) ||
        (game.storyline != null && game.storyline!.isNotEmpty);
  }

  bool _hasGameFeatures(Game game) {
    return game.gameModes.isNotEmpty ||
        game.playerPerspectives.isNotEmpty ||
        game.hasMultiplayer;
  }

  // ✅ PREVIEW BUILDERS - Build preview text for collapsed state (unchanged)
  Widget _buildUserStatesPreview(BuildContext context, Game game) {
    List<String> activeStates = [];

    if (game.userRating != null) {
      activeStates.add('⭐${(game.userRating! * 10).toStringAsFixed(1)}');
    }

    if (game.isWishlisted == true) {
      activeStates.add('❤️');
    }

    if (game.isRecommended == true) {
      activeStates.add('👍');
    }

    if (game.isInTopThree == true) {
      activeStates.add('🏆#${game.topThreePosition ?? 1}');
    }

    if (activeStates.isEmpty) {
      return Text(
        'No activity',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      activeStates.join(' • '),
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildGameInfoPreview(BuildContext context, Game game) {
    List<String> info = [];

    if (game.gameType != null) {
      info.add(_formatLabel(game.gameType!.name));
    }

    if (game.gameStatus != null) {
      info.add(_formatLabel(game.gameStatus!.name));
    }

    if (game.versionTitle != null && game.versionTitle!.isNotEmpty) {
      info.add(game.versionTitle!);
    }

    if (game.alternativeNames.isNotEmpty) {
      info.add('${game.alternativeNames.length} alt names');
    }

    if (info.isEmpty) {
      return Text(
        'Basic information',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      info.join(' • '),
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCommunityPreview(BuildContext context, Game game) {
    List<String> info = [];

    if (game.totalRating != null) {
      info.add('⭐${game.totalRating!.toStringAsFixed(1)}');
    } else if (game.rating != null) {
      info.add('⭐${game.rating!.toStringAsFixed(1)}');
    } else if (game.aggregatedRating != null) {
      info.add('⭐${game.aggregatedRating!.toStringAsFixed(1)}');
    }

    if (game.hypes != null && game.hypes! > 0) {
      info.add('❤️${_formatNumber(game.hypes!)}');
    }

    if (game.firstReleaseDate != null) {
      info.add('📅${DateFormatter.formatYearOnly(game.firstReleaseDate!)}');
    }

    return Text(
      info.join(' • '),
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDescriptionPreview(BuildContext context, Game game) {
    String preview = '';

    if (game.summary != null && game.summary!.isNotEmpty) {
      preview = game.summary!.length > 80
          ? '${game.summary!.substring(0, 80)}...'
          : game.summary!;
    } else if (game.storyline != null && game.storyline!.isNotEmpty) {
      preview = game.storyline!.length > 80
          ? '${game.storyline!.substring(0, 80)}...'
          : game.storyline!;
    }

    return Text(
      preview,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEnginesPreview(BuildContext context, Game game) {
    if (game.gameEngines.isEmpty) return const SizedBox.shrink();

    List<String> engineNames = game.gameEngines.take(2).map((e) => e.name).toList();
    String preview = engineNames.join(' • ');

    if (game.gameEngines.length > 2) {
      preview += ' • +${game.gameEngines.length - 2} more';
    }

    return Text(
      preview,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPlatformsPreview(BuildContext context, Game game) {
    if (game.platforms.isEmpty) return const SizedBox.shrink();

    List<String> platformNames = game.platforms.take(3).map((p) => p.abbreviation ?? p.name).toList();
    String preview = platformNames.join(' • ');

    if (game.platforms.length > 3) {
      preview += ' • +${game.platforms.length - 3} more';
    }

    return Text(
      preview,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildGenresPreview(BuildContext context, Game game) {
    List<String> categories = [];

    if (game.genres.isNotEmpty) {
      categories.addAll(game.genres.take(2).map((g) => g.name));
    }

    if (categories.length < 2 && game.themes.isNotEmpty) {
      categories.addAll(game.themes.take(2 - categories.length).map((t) => t));
    }

    String preview = categories.join(' • ');

    int totalCount = game.genres.length + game.themes.length;
    if (totalCount > 2) {
      preview += ' • +${totalCount - 2} more';
    }

    return Text(
      preview.isNotEmpty ? preview : 'Categories',
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildGameFeaturesPreview(BuildContext context, Game game) {
    List<String> features = [];

    if (game.gameModes.isNotEmpty) {
      features.addAll(game.gameModes.take(2).map((m) => m.name));
    }

    if (game.hasMultiplayer) {
      features.add('Multiplayer');
    }

    if (features.length < 3 && game.playerPerspectives.isNotEmpty) {
      features.addAll(game.playerPerspectives.take(3 - features.length).map((p) => p.name));
    }

    String preview = features.take(3).join(' • ');

    return Text(
      preview.isNotEmpty ? preview : 'Game features',
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAgeRatingsPreview(BuildContext context, Game game) {
    if (game.ageRatings.isEmpty) return const SizedBox.shrink();

    List<String> ratings = [];

    for (var rating in game.ageRatings.take(2)) {
      String orgName = rating.organizationName;
      String ratingName = rating.displayName;
      ratings.add('$orgName $ratingName');
    }

    String preview = ratings.join(' • ');

    if (game.ageRatings.length > 2) {
      preview += ' • +${game.ageRatings.length - 2} more';
    }

    return Text(
      preview,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCompaniesPreview(BuildContext context, Game game) {
    if (game.involvedCompanies.isEmpty) return const SizedBox.shrink();

    List<String> companies = [];

    for (var involved in game.involvedCompanies.take(2)) {
      if (involved.company != null) {
        companies.add(involved.company!.name);
      }
    }

    String preview = companies.join(' • ');

    if (game.involvedCompanies.length > 2) {
      preview += ' • +${game.involvedCompanies.length - 2} more';
    }

    return Text(
      preview,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildExternalLinksPreview(BuildContext context, Game game) {
    List<String> stores = [];

    for (var extGame in game.externalGames.take(3)) {
      if (extGame.url?.contains('steam') == true) stores.add('Steam');
      else if (extGame.url?.contains('epic') == true) stores.add('Epic');
      else if (extGame.url?.contains('gog') == true) stores.add('GOG');
      else if (extGame.url?.contains('playstation') == true) stores.add('PlayStation');
      else if (extGame.url?.contains('xbox') == true) stores.add('Xbox');
    }

    stores = stores.toSet().toList();
    int totalLinks = game.websites.length + game.externalGames.length;

    String preview = stores.take(2).join(' • ');
    if (totalLinks > stores.length) {
      preview += preview.isNotEmpty ? ' • +${totalLinks - stores.length} more' : '$totalLinks links';
    }

    return Text(
      preview.isNotEmpty ? preview : 'External links',
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatLabel(String label) {
    return label
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}

// ✅ Enhanced Accordion Tile (unchanged)
class EnhancedAccordionTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? preview;
  final bool initiallyExpanded;

  const EnhancedAccordionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.preview,
    this.initiallyExpanded = false,
  });

  @override
  State<EnhancedAccordionTile> createState() => _EnhancedAccordionTileState();
}

class _EnhancedAccordionTileState extends State<EnhancedAccordionTile> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: _isExpanded ? 1.5 : 1,
        ),
        color: _isExpanded
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.05)
            : null,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: _isExpanded ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ) : null,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isExpanded
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                            : Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isExpanded ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Icon(
                        widget.icon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isExpanded
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          if (!_isExpanded && widget.preview != null) ...[
                            const SizedBox(height: 4),
                            widget.preview!,
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _isExpanded
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: widget.child,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}