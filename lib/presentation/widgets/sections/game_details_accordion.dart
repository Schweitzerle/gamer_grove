// ==================================================
// SIMPLIFIED GAME DETAILS ACCORDION - Without Callbacks
// ==================================================

// lib/presentation/widgets/sections/game_details_accordion.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/utils/date_formatter.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/website/website_type.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/community_info_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/company_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/game_description_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/user_states_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/age_ratings_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/external_links_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/game_engines_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/game_features_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/genre_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/platform_section.dart';

class GameDetailsAccordion extends StatelessWidget {
  const GameDetailsAccordion({
    required this.game,
    super.key,
  });
  final Game game;

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
              // ✅ Use BlocBuilder for preview to get live data from UserGameDataBloc
              BlocBuilder<UserGameDataBloc, UserGameDataState>(
                builder: (context, userDataState) {
                  return EnhancedAccordionTile(
                    title: 'Your Activity',
                    icon: Icons.person,
                    iconColor: const Color(0xFF6366F1), // Indigo
                    preview:
                        _buildUserStatesPreview(context, game, userDataState),
                    child: UserStatesContent(
                      game: game,
                    ), // ✅ Simplified - no callbacks needed
                  );
                },
              ),

              // Community & Ratings
              if (_hasCommunityInfo(game))
                EnhancedAccordionTile(
                  title: 'Community & Ratings',
                  icon: Icons.public,
                  iconColor: const Color(0xFF8B5CF6), // Purple
                  preview: _buildCommunityPreview(context, game),
                  noPadding: true,
                  child: CommunityInfoContent(game: game),
                ),

              // Game Description
              if (_hasGameDescription(game))
                EnhancedAccordionTile(
                  title: 'About ${game.name}',
                  icon: Icons.description,
                  iconColor: const Color(0xFFA855F7), // Light Purple
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
            color: Theme.of(context).colorScheme.primary,
            children: [
              // Development Tools
              if (game.gameEngines.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Development Tools',
                  icon: Icons.precision_manufacturing_rounded,
                  iconColor: const Color(0xFF10B981), // Emerald
                  preview: _buildEnginesPreview(context, game),
                  noPadding: true,
                  child: GameEnginesSection(gameEngines: game.gameEngines),
                ),

              // Platforms & Release
              if (game.platforms.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Platforms & Release',
                  icon: Icons.devices,
                  iconColor: const Color(0xFF3B82F6), // Blue
                  preview: _buildPlatformsPreview(context, game),
                  noPadding: true,
                  child: GenericPlatformSection(
                    game: game,
                  ),
                ),

              // Genres & Categories
              if (game.genres.isNotEmpty || game.themes.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Genres & Categories',
                  icon: Icons.category,
                  iconColor: const Color(0xFF06B6D4), // Cyan
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
            color: Theme.of(context).colorScheme.primary,
            children: [
              // Game Features
              if (_hasGameFeatures(game))
                EnhancedAccordionTile(
                  title: 'Game Features',
                  icon: Icons.featured_play_list,
                  iconColor: const Color(0xFFF59E0B), // Amber
                  preview: _buildGameFeaturesPreview(context, game),
                  child: GameFeaturesSection(game: game),
                ),

              // Age Ratings
              if (game.ageRatings.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Age Ratings',
                  icon: Icons.verified_user,
                  iconColor: const Color(0xFFEF4444), // Red
                  preview: _buildAgeRatingsPreview(context, game),
                  noPadding: true,
                  child: AgeRatingsSection(ageRatings: game.ageRatings),
                ),

              // Companies
              if (game.involvedCompanies.isNotEmpty)
                EnhancedAccordionTile(
                  title: 'Companies',
                  icon: Icons.business,
                  iconColor: const Color(0xFF8B5CF6), // Purple
                  preview: _buildCompaniesPreview(context, game),
                  noPadding: true,
                  child: GenericCompanySection(
                    involvedCompanies: game.involvedCompanies,
                    title: 'Development & Publishing',
                  ),
                ),

              // External Links & Stores
              if (_hasExternalLinks(game))
                EnhancedAccordionTile(
                  title: 'External Links & Stores',
                  icon: Icons.link,
                  iconColor: const Color(0xFF14B8A6), // Teal
                  preview: _buildExternalLinksPreview(context, game),
                  noPadding: true,
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
    final validChildren =
        children.where((child) => child != const SizedBox.shrink()).toList();

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
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

  bool _hasExternalLinks(Game game) {
    // Check if there are external games/stores
    if (game.externalGames.isNotEmpty) {
      return true;
    }

    // Show if there are any websites (including social media, stores, etc.)
    // The only case we want to hide this section is if there are NO websites at all
    // or ONLY a single official website with no other links
    if (game.websites.isNotEmpty) {
      // If there's more than one website, show the section
      if (game.websites.length > 1) {
        return true;
      }

      // If there's only one website, check if it's NOT just an official site
      return game.websites.first.type != WebsiteCategory.official;
    }

    return false;
  }

  // ✅ PREVIEW BUILDERS - Build preview text for collapsed state
  // ✅ UPDATED: Now reads from UserGameDataBloc for live data
  Widget _buildUserStatesPreview(
    BuildContext context,
    Game game,
    UserGameDataState userDataState,
  ) {
    final activeStates = <String>[];

    // Read from UserGameDataBloc if available, fallback to Game entity
    double? userRating;
    var isWishlisted = false;
    var isRecommended = false;
    var isInTopThree = false;
    int? topThreePosition;

    if (userDataState is UserGameDataLoaded) {
      userRating = userDataState.getRating(game.id);
      isWishlisted = userDataState.isWishlisted(game.id);
      isRecommended = userDataState.isRecommended(game.id);
      isInTopThree = userDataState.isInTopThree(game.id);
      topThreePosition = userDataState.getTopThreePosition(game.id);
    } else {
      // Fallback to Game entity data
      userRating = game.userRating;
      isWishlisted = game.isWishlisted;
      isRecommended = game.isRecommended;
      isInTopThree = game.isInTopThree;
      topThreePosition = game.topThreePosition;
    }

    // Build preview string
    if (userRating != null) {
      activeStates.add('⭐${(userRating * 10).toStringAsFixed(1)}');
    }

    if (isWishlisted) {
      activeStates.add('❤️');
    }

    if (isRecommended) {
      activeStates.add('👍');
    }

    if (isInTopThree) {
      activeStates.add('🏆#${topThreePosition ?? 1}');
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

  Widget _buildCommunityPreview(BuildContext context, Game game) {
    final info = <String>[];

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
    var preview = '';

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

    final engineNames = game.gameEngines.take(2).map((e) => e.name).toList();
    var preview = engineNames.join(' • ');

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

    final platformNames =
        game.platforms.take(3).map((p) => p.abbreviation ?? p.name).toList();
    var preview = platformNames.join(' • ');

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
    final categories = <String>[];

    if (game.genres.isNotEmpty) {
      categories.addAll(game.genres.take(2).map((g) => g.name));
    }

    if (categories.length < 2 && game.themes.isNotEmpty) {
      categories
          .addAll(game.themes.take(2 - categories.length).map((t) => t.name));
    }

    var preview = categories.join(' • ');

    final totalCount = game.genres.length + game.themes.length;
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
    final features = <String>[];

    if (game.gameModes.isNotEmpty) {
      features.addAll(game.gameModes.take(2).map((m) => m.name));
    }

    if (game.hasMultiplayer) {
      features.add('Multiplayer');
    }

    if (features.length < 3 && game.playerPerspectives.isNotEmpty) {
      features.addAll(
        game.playerPerspectives.take(3 - features.length).map((p) => p.name),
      );
    }

    final preview = features.take(3).join(' • ');

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

    final ratings = <String>[];

    for (final rating in game.ageRatings.take(2)) {
      final orgName = rating.organizationName;
      final ratingName = rating.displayName;
      ratings.add('$orgName $ratingName');
    }

    var preview = ratings.join(' • ');

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

    final companies = <String>[];

    for (final involved in game.involvedCompanies.take(2)) {
      companies.add(involved.company.name);
    }

    var preview = companies.join(' • ');

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
    var stores = <String>[];

    for (final extGame in game.externalGames.take(3)) {
      if (extGame.url?.contains('steam') ?? false) {
        stores.add('Steam');
      } else if (extGame.url?.contains('epic') ?? false)
        stores.add('Epic');
      else if (extGame.url?.contains('gog') ?? false)
        stores.add('GOG');
      else if (extGame.url?.contains('playstation') ?? false)
        stores.add('PlayStation');
      else if (extGame.url?.contains('xbox') ?? false) stores.add('Xbox');
    }

    stores = stores.toSet().toList();
    final totalLinks = game.websites.length + game.externalGames.length;

    var preview = stores.take(2).join(' • ');
    if (totalLinks > stores.length) {
      preview += preview.isNotEmpty
          ? ' • +${totalLinks - stores.length} more'
          : '$totalLinks links';
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

// ✅ Enhanced Accordion Tile
class EnhancedAccordionTile extends StatefulWidget {
  const EnhancedAccordionTile({
    required this.title,
    required this.icon,
    required this.child,
    super.key,
    this.iconColor,
    this.preview,
    this.initiallyExpanded = false,
    this.noPadding = false,
  });
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  final Widget? preview;
  final bool initiallyExpanded;
  final bool noPadding;

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
              ? (widget.iconColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: _isExpanded ? 1.5 : 1,
        ),
        color: _isExpanded
            ? (widget.iconColor ?? Theme.of(context).colorScheme.primary)
                .withOpacity(0.05)
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
                decoration: _isExpanded
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (widget.iconColor ??
                                    Theme.of(context).colorScheme.primary)
                                .withOpacity(0.1),
                            (widget.iconColor ??
                                    Theme.of(context).colorScheme.primary)
                                .withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      )
                    : null,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isExpanded
                            ? (widget.iconColor ??
                                    Theme.of(context).colorScheme.primary)
                                .withOpacity(0.15)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: !_isExpanded
                            ? Border.all(
                                color: (widget.iconColor ??
                                        Theme.of(context).colorScheme.primary)
                                    .withOpacity(0.3),
                              )
                            : null,
                        boxShadow: _isExpanded
                            ? [
                                BoxShadow(
                                  color: (widget.iconColor ??
                                          Theme.of(context).colorScheme.primary)
                                      .withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor ??
                            Theme.of(context).colorScheme.primary,
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _isExpanded
                                      ? (widget.iconColor ??
                                          Theme.of(context).colorScheme.primary)
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
                            ? (widget.iconColor ??
                                Theme.of(context).colorScheme.primary)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              heightFactor: _isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Container(
                padding: widget.noPadding
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
