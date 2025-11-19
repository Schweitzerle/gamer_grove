// ==================================================
// ENHANCED EXTERNAL LINKS SECTION - MIT FONTAWESOME & HORIZONTAL CARDS
// ==================================================

// lib/presentation/widgets/sections/enhanced_external_links_section.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/externalGame/external_game.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/website/website.dart';

class ExternalLinksSection extends StatelessWidget {
  final Game game;

  const ExternalLinksSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    // Separate websites and stores
    final websites = game.websites;
    // Filter stores: only show those with a valid URL (clickable)
    final storesWithUrl = game.externalGames
        .where((store) => store.storeUrl != null && store.storeUrl!.isNotEmpty)
        .toList();
    final hasIgdbUrl = game.url != null && game.url!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ WEBSITES SECTION (Social Media, Official Sites, etc.)
        if (websites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppConstants.paddingSmall),
            child: _buildWebsitesSection(context, websites),
          ),
        ],

        // ✅ DIGITAL STORES SECTION (Steam, Epic, PlayStation Store, etc.)
        if (storesWithUrl.isNotEmpty) ...[
          if (websites.isNotEmpty) const SizedBox(height: 20),
          _buildStoresSection(context, storesWithUrl),
        ],

        // ✅ DATABASE LINKS SECTION (IGDB)
        if (hasIgdbUrl) ...[
          if (websites.isNotEmpty || storesWithUrl.isNotEmpty)
            const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
            child: _buildDatabaseLinksSection(context),
          ),
        ],
      ],
    );
  }

  // ✅ DATABASE LINKS SECTION (IGDB)
  Widget _buildDatabaseLinksSection(BuildContext context) {
    const igdbColor = Color(0xFF9146FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Database Links',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // IGDB Card
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: AppConstants.paddingSmall),
            children: [
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: igdbColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: igdbColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _launchUrl(game.url!),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // IGDB Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: igdbColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.database,
                              color: igdbColor,
                              size: 20,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // IGDB Name
                          Text(
                            'IGDB',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: igdbColor,
                                    ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ WEBSITES SECTION (Social Media & Official Links)
  Widget _buildWebsitesSection(BuildContext context, List<Website> websites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
          child: Row(
            children: [
              Icon(
                Icons.public,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Official & Social Links',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${websites.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Website Cards
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: AppConstants.paddingSmall),
            itemCount: websites.length,
            itemBuilder: (context, index) {
              final website = websites[index];
              return Padding(
                padding: const EdgeInsets.only(
                  right: AppConstants.paddingSmall,
                ),
                child: _buildWebsiteCard(context, website),
              );
            },
          ),
        ),
      ],
    );
  }

  // ✅ STORES SECTION (Digital Platforms)
  Widget _buildStoresSection(BuildContext context, List<ExternalGame> stores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
          child: Row(
            children: [
              Icon(
                Icons.shopping_bag,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Digital Stores',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stores.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Store Cards
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: AppConstants.paddingSmall),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return Padding(
                padding: const EdgeInsets.only(
                  right: AppConstants.paddingSmall,
                ),
                child: _buildStoreCard(context, store),
              );
            },
          ),
        ),
      ],
    );
  }

  // ✅ WEBSITE CARD WIDGET
  Widget _buildWebsiteCard(BuildContext context, Website website) {
    final websiteColor = _getWebsiteColor(website.type.type);
    final websiteName = _getWebsiteName(website.type.type);

    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: websiteColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: websiteColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchUrl(website.url),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Website Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: websiteColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _getWebsiteIcon(website),
                ),

                const SizedBox(height: 6),

                // Website Name
                Text(
                  websiteName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: websiteColor,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ STORE CARD WIDGET
  Widget _buildStoreCard(BuildContext context, ExternalGame store) {
    final storeColor = _getStoreColor(context, store.categoryEnum);
    final storeName = _getStoreName(store.categoryEnum);

    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: storeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: storeColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchStoreUrl(store),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Store Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: storeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStoreIcon(store.categoryEnum),
                    color: storeColor,
                    size: 20,
                  ),
                ),

                const SizedBox(height: 6),

                // Store Name
                Text(
                  storeName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: storeColor,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== WEBSITE HELPER METHODS =====
  String _getWebsiteName(String type) {
    switch (type.toLowerCase()) {
      // Official API type names
      case 'official website':
        return 'Official';
      case 'community wiki':
        return 'Wiki';
      case 'wikipedia':
        return 'Wikipedia';
      case 'facebook':
        return 'Facebook';
      case 'twitter':
        return 'Twitter';
      case 'twitch':
        return 'Twitch';
      case 'instagram':
        return 'Instagram';
      case 'youtube':
        return 'YouTube';
      case 'subreddit':
        return 'Reddit';
      case 'discord':
        return 'Discord';
      case 'steam':
        return 'Steam';
      case 'epic':
        return 'Epic';
      case 'gog':
        return 'GOG';
      case 'itch':
        return 'itch.io';
      case 'app store (iphone)':
        return 'App Store';
      case 'app store (ipad)':
        return 'App Store';
      case 'google play':
        return 'Google Play';
      case 'bluesky':
        return 'Bluesky';
      case 'xbox':
        return 'Xbox';
      case 'playstation':
        return 'PlayStation';
      case 'nintendo':
        return 'Nintendo';
      case 'meta':
        return 'Meta';
      // Legacy support (old enum names)
      case 'official':
        return 'Official';
      case 'wikia':
        return 'Wiki';
      case 'reddit':
        return 'Reddit';
      case 'epicgames':
        return 'Epic';
      case 'iphone':
      case 'ipad':
        return 'App Store';
      case 'android':
        return 'Google Play';
      default:
        return type;
    }
  }

  Widget _getWebsiteIcon(Website website) {
    final typeStr = website.type.type.toLowerCase();
    print('🌐 Website Type: "$typeStr" (original: "${website.type.type}")');
    IconData iconData;
    Color iconColor;

    switch (typeStr) {
      // Official API type names
      case 'official website':
      case 'official':
        iconData = Icons.public;
        iconColor = const Color(0xFF07355A);
      case 'community wiki':
      case 'wikia':
        iconData = FontAwesomeIcons.wikipediaW;
        iconColor = const Color(0xFF939598);
      case 'wikipedia':
        iconData = FontAwesomeIcons.wikipediaW;
        iconColor = const Color(0xFFc7c8ca);
      case 'facebook':
        iconData = FontAwesomeIcons.facebook;
        iconColor = const Color(0xFF1877f2);
      case 'twitter':
        iconData = FontAwesomeIcons.twitter;
        iconColor = const Color(0xFF1da1f2);
      case 'twitch':
        iconData = FontAwesomeIcons.twitch;
        iconColor = const Color(0xFF9146ff);
      case 'instagram':
        iconData = FontAwesomeIcons.instagram;
        iconColor = const Color(0xFFc13584);
      case 'youtube':
        iconData = FontAwesomeIcons.youtube;
        iconColor = const Color(0xFFff0000);
      case 'app store (iphone)':
      case 'app store (ipad)':
      case 'iphone':
      case 'ipad':
        iconData = FontAwesomeIcons.apple;
        iconColor = const Color(0xFF000000);
      case 'google play':
      case 'android':
        iconData = FontAwesomeIcons.android;
        iconColor = const Color(0xFFa4c639);
      case 'steam':
        iconData = FontAwesomeIcons.steam;
        iconColor = const Color(0xFF00adee);
      case 'subreddit':
      case 'reddit':
        iconData = FontAwesomeIcons.reddit;
        iconColor = const Color(0xFFff4500);
      case 'itch':
        iconData = FontAwesomeIcons.itchIo;
        iconColor = const Color(0xFFfa5c5c);
      case 'epic':
      case 'epicgames':
        iconData = FontAwesomeIcons.earlybirds;
        iconColor = const Color(0xFF242424);
      case 'gog':
        iconData = FontAwesomeIcons.galacticRepublic;
        iconColor = const Color(0xFF7cb4dc);
      case 'discord':
        iconData = FontAwesomeIcons.discord;
        iconColor = const Color(0xFF5865f2);
      case 'bluesky':
        iconData = FontAwesomeIcons.cloud;
        iconColor = const Color(0xFF0085FF);
      case 'xbox':
        iconData = FontAwesomeIcons.xbox;
        iconColor = const Color(0xFF107C10);
      case 'playstation':
        iconData = FontAwesomeIcons.playstation;
        iconColor = const Color(0xFF0070D1);
      case 'nintendo':
        iconData = FontAwesomeIcons.gamepad;
        iconColor = const Color(0xFFE60012);
      case 'meta':
        iconData = FontAwesomeIcons.meta;
        iconColor = const Color(0xFF0668E1);
      default:
        iconData = Icons.link;
        iconColor = const Color(0xFF07355A);
    }

    return Icon(iconData, color: iconColor, size: 20);
  }

  Color _getWebsiteColor(String type) {
    switch (type.toLowerCase()) {
      // Official API type names
      case 'official website':
      case 'official':
        return Colors.blue;
      case 'community wiki':
      case 'wikia':
      case 'wikipedia':
        return Colors.orange;
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return Colors.black;
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'twitch':
        return const Color(0xFF9146FF);
      case 'subreddit':
      case 'reddit':
        return const Color(0xFFFF4500);
      case 'discord':
        return const Color(0xFF5865F2);
      case 'steam':
        return const Color(0xFF1B2838);
      case 'epic':
      case 'epicgames':
        return const Color(0xFF0078F2);
      case 'gog':
        return const Color(0xFF8A2BE2);
      case 'itch':
        return const Color(0xFFFA5C5C);
      case 'app store (iphone)':
      case 'app store (ipad)':
      case 'iphone':
      case 'ipad':
        return const Color(0xFF007AFF);
      case 'google play':
      case 'android':
        return const Color(0xFF3DDC84);
      case 'bluesky':
        return const Color(0xFF0085FF);
      case 'xbox':
        return const Color(0xFF107C10);
      case 'playstation':
        return const Color(0xFF0070D1);
      case 'nintendo':
        return const Color(0xFFE60012);
      case 'meta':
        return const Color(0xFF0668E1);
      default:
        return Colors.blue;
    }
  }

  // ===== STORE HELPER METHODS =====
  String _getStoreName(ExternalGameCategoryEnum? category) {
    if (category == null) return 'Store';
    // Use the enum's displayName getter for string-based approach
    return category.displayName;
  }

  IconData _getStoreIcon(ExternalGameCategoryEnum? category) {
    if (category == null) return Icons.store;

    // Use enum's name property for string-based mapping
    switch (category.name.toLowerCase()) {
      case 'steam':
        return FontAwesomeIcons.steam;
      case 'gog':
        return FontAwesomeIcons.galacticRepublic;
      case 'epicgamestore':
        return FontAwesomeIcons.gamepad;
      case 'playstationstoreus':
        return FontAwesomeIcons.playstation;
      case 'xboxmarketplace':
      case 'microsoft':
      case 'xboxgamepassultimatecloud':
        return FontAwesomeIcons.xbox;
      case 'apple':
        return FontAwesomeIcons.apple;
      case 'android':
        return FontAwesomeIcons.android;
      case 'itchio':
        return FontAwesomeIcons.itchIo;
      case 'amazonluna':
      case 'amazonadg':
      case 'amazonasin':
        return FontAwesomeIcons.amazon;
      case 'oculus':
        return FontAwesomeIcons.vrCardboard;
      case 'twitch':
        return FontAwesomeIcons.twitch;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'utomik':
        return FontAwesomeIcons.gamepad;
      case 'kartridge':
        return FontAwesomeIcons.solidCircle;
      case 'focusentertainment':
        return FontAwesomeIcons.gamepad;
      case 'gamejolt':
        return FontAwesomeIcons.bolt;
      default:
        return Icons.store;
    }
  }

  Color _getStoreColor(
      BuildContext context, ExternalGameCategoryEnum? category) {
    if (category == null) return Theme.of(context).colorScheme.primary;

    // Use enum's name property for string-based mapping
    switch (category.name.toLowerCase()) {
      case 'steam':
        return const Color(0xFF1B2838);
      case 'gog':
        return const Color(0xFF8A2BE2);
      case 'epicgamestore':
        return const Color(0xFF0078F2);
      case 'playstationstoreus':
        return const Color(0xFF0070D1);
      case 'xboxmarketplace':
        return const Color(0xFF107C10);
      case 'microsoft':
      case 'xboxgamepassultimatecloud':
        return const Color(0xFF00BCF2);
      case 'apple':
        return const Color(0xFF007AFF);
      case 'android':
        return const Color(0xFF3DDC84);
      case 'itchio':
        return const Color(0xFFFA5C5C);
      case 'amazonluna':
      case 'amazonadg':
      case 'amazonasin':
        return const Color(0xFFFF9900);
      case 'oculus':
        return const Color(0xFF1C1E20);
      case 'twitch':
        return const Color(0xFF9146FF);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'utomik':
        return const Color(0xFF6B46C1);
      case 'kartridge':
        return const Color(0xFFE53E3E);
      case 'focusentertainment':
        return const Color(0xFF2D3748);
      case 'gamejolt':
        return const Color(0xFF2F7D32);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  // ===== URL LAUNCHING =====
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Future<void> _launchStoreUrl(ExternalGame store) async {
    try {
      // Use the storeUrl getter from ExternalGame entity
      String? url = store.storeUrl;
      if (url != null) {
        await _launchUrl(url);
      }
    } catch (e) {
      print('Error launching store URL: $e');
    }
  }
}
