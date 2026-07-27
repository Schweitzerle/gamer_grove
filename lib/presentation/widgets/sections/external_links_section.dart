// ==================================================
// ENHANCED EXTERNAL LINKS SECTION - MIT FONTAWESOME & HORIZONTAL CARDS
// ==================================================

// lib/presentation/widgets/sections/enhanced_external_links_section.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/theme/brand_colors.dart';
import 'package:gamer_grove/core/theme/gg_contrast.dart';
import 'package:gamer_grove/domain/entities/externalGame/external_game.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/website/website.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLinksSection extends StatelessWidget {
  const ExternalLinksSection({
    required this.game,
    super.key,
  });
  final Game game;

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

  /// A service's mark, lifted until it reads on the current surface.
  ///
  /// The lift is what stops Apple's black and Epic's near-black from vanishing
  /// in the cave, and because it is computed against the live surface the same
  /// table also works in the light theme. The bar is 4.5:1 rather than the 3:1
  /// for icons, because this colour carries the label text too.
  Color _brandColor(BuildContext context, String? brand) {
    final scheme = Theme.of(context).colorScheme;
    final mark = BrandColors.of(brand) ?? scheme.primary;
    return mark.legibleOn(scheme.surface, minimum: 4.5);
  }

  // ✅ WEBSITE CARD WIDGET
  Widget _buildWebsiteCard(BuildContext context, Website website) {
    final websiteColor =
        _brandColor(context, _brandOfWebsite(website.type.type));
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
                  child: Icon(
                    _getWebsiteIcon(website),
                    color: websiteColor,
                    size: 20,
                  ),
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

  IconData _getWebsiteIcon(Website website) {
    switch (website.type.type.toLowerCase()) {
      case 'community wiki':
      case 'wikia':
      case 'wikipedia':
        return FontAwesomeIcons.wikipediaW;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'twitch':
        return FontAwesomeIcons.twitch;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'app store (iphone)':
      case 'app store (ipad)':
      case 'iphone':
      case 'ipad':
        return FontAwesomeIcons.apple;
      case 'google play':
      case 'android':
        return FontAwesomeIcons.android;
      case 'steam':
        return FontAwesomeIcons.steam;
      case 'subreddit':
      case 'reddit':
        return FontAwesomeIcons.reddit;
      case 'itch':
        return FontAwesomeIcons.itchIo;
      case 'epic':
      case 'epicgames':
        return FontAwesomeIcons.earlybirds;
      case 'gog':
        return FontAwesomeIcons.galacticRepublic;
      case 'discord':
        return FontAwesomeIcons.discord;
      case 'bluesky':
        return FontAwesomeIcons.cloud;
      case 'xbox':
        return FontAwesomeIcons.xbox;
      case 'playstation':
        return FontAwesomeIcons.playstation;
      case 'nintendo':
        return FontAwesomeIcons.gamepad;
      case 'meta':
        return FontAwesomeIcons.meta;
      case 'official website':
      case 'official':
        return Icons.public;
      default:
        return Icons.link;
    }
  }

  /// The IGDB website type mapped onto a service in [BrandColors].
  ///
  /// Null for an official site or an unrecognised type: there is no brand to
  /// borrow, so those take the app's own accent.
  String? _brandOfWebsite(String type) {
    switch (type.toLowerCase()) {
      case 'community wiki':
      case 'wikia':
      case 'wikipedia':
        return 'wikipedia';
      case 'app store (iphone)':
      case 'app store (ipad)':
      case 'iphone':
      case 'ipad':
        return 'apple';
      case 'google play':
      case 'android':
        return 'android';
      case 'subreddit':
      case 'reddit':
        return 'reddit';
      case 'epic':
      case 'epicgames':
        return 'epic';
      case 'facebook':
      case 'twitter':
      case 'twitch':
      case 'instagram':
      case 'youtube':
      case 'steam':
      case 'itch':
      case 'gog':
      case 'discord':
      case 'bluesky':
      case 'xbox':
      case 'playstation':
      case 'nintendo':
      case 'meta':
        return type.toLowerCase();
      default:
        return null;
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
    BuildContext context,
    ExternalGameCategoryEnum? category,
  ) =>
      _brandColor(context, _brandOfStore(category));

  /// The IGDB store category mapped onto a service in [BrandColors].
  ///
  /// Stores without a published mark of their own (Utomik, Kartridge, Focus)
  /// return null and take the app's accent, rather than carrying a colour
  /// somebody once picked for them.
  String? _brandOfStore(ExternalGameCategoryEnum? category) {
    if (category == null) return null;
    switch (category.name.toLowerCase()) {
      case 'epicgamestore':
        return 'epic';
      case 'playstationstoreus':
        return 'playstation';
      case 'xboxmarketplace':
        return 'xbox';
      case 'microsoft':
      case 'xboxgamepassultimatecloud':
        return 'microsoft';
      case 'itchio':
        return 'itch';
      case 'amazonluna':
      case 'amazonadg':
      case 'amazonasin':
        return 'amazon';
      case 'steam':
      case 'gog':
      case 'apple':
      case 'android':
      case 'oculus':
      case 'twitch':
      case 'youtube':
      case 'gamejolt':
        return category.name.toLowerCase();
      default:
        return null;
    }
  }

  // ===== URL LAUNCHING =====
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {}
  }

  Future<void> _launchStoreUrl(ExternalGame store) async {
    try {
      // Use the storeUrl getter from ExternalGame entity
      final url = store.storeUrl;
      if (url != null) {
        await _launchUrl(url);
      }
    } catch (e) {}
  }
}
