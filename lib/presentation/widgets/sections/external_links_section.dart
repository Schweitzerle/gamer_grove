// ==================================================
// ENHANCED EXTERNAL LINKS SECTION - MIT FONTAWESOME & HORIZONTAL CARDS
// ==================================================

// lib/presentation/widgets/sections/enhanced_external_links_section.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/website/website.dart';
import '../../../domain/entities/externalGame/external_game.dart';
import '../../../domain/entities/website/website_type.dart';

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
    final stores = game.externalGames;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ WEBSITES SECTION (Social Media, Official Sites, etc.)
        if (websites.isNotEmpty) ...[
          _buildWebsitesSection(context, websites),
        ],

        // ✅ DIGITAL STORES SECTION (Steam, Epic, PlayStation Store, etc.)
        if (stores.isNotEmpty) ...[
          if (websites.isNotEmpty) const SizedBox(height: 20),
          _buildStoresSection(context, stores),
        ],
      ],
    );
  }

  // ✅ WEBSITES SECTION (Social Media & Official Links)
  Widget _buildWebsitesSection(BuildContext context, List<Website> websites) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
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
        const SizedBox(height: 12),

        // Horizontal Website Cards
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: websites.length,
            itemBuilder: (context, index) {
              final website = websites[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < websites.length - 1 ? 12 : 0,
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
        Row(
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
        const SizedBox(height: 12),

        // Horizontal Store Cards
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < stores.length - 1 ? 12 : 0,
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
    final websiteColor = _getWebsiteColor(website.category);
    final websiteName = _getWebsiteName(website.category);

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

  // ✅ YOUR EXISTING HELPER METHODS (from paste.txt)

  // ===== WEBSITE HELPER METHODS =====
  String _getWebsiteName(WebsiteCategory category) {
    switch (category) {
      case WebsiteCategory.official:
        return 'Official Website';
      case WebsiteCategory.wikia:
        return 'Wikia';
      case WebsiteCategory.wikipedia:
        return 'Wikipedia';
      case WebsiteCategory.facebook:
        return 'Facebook';
      case WebsiteCategory.twitter:
        return 'Twitter';
      case WebsiteCategory.twitch:
        return 'Twitch';
      case WebsiteCategory.instagram:
        return 'Instagram';
      case WebsiteCategory.youtube:
        return 'YouTube';
      case WebsiteCategory.reddit:
        return 'Reddit';
      case WebsiteCategory.discord:
        return 'Discord';
      case WebsiteCategory.steam:
        return 'Steam';
      case WebsiteCategory.epicgames:
        return 'Epic Games';
      case WebsiteCategory.gog:
        return 'GOG';
      case WebsiteCategory.itch:
        return 'itch.io';
      case WebsiteCategory.iphone:
        return 'App Store (iPhone)';
      case WebsiteCategory.ipad:
        return 'App Store (iPad)';
      case WebsiteCategory.android:
        return 'Google Play';
      case WebsiteCategory.bluesky:
        return 'Bluesky';
    }
  }

  Widget _getWebsiteIcon(Website website) {
    IconData iconData;
    Color iconColor;
    switch (website.category) {
      case WebsiteCategory.official:
        iconData = Icons.public;
        iconColor = const Color(0xFF07355A);
        break;
      case WebsiteCategory.wikia:
        iconData = FontAwesomeIcons.wikipediaW;
        iconColor = const Color(0xFF939598);
        break;
      case WebsiteCategory.wikipedia:
        iconData = FontAwesomeIcons.wikipediaW;
        iconColor = const Color(0xFFc7c8ca);
        break;
      case WebsiteCategory.facebook:
        iconData = FontAwesomeIcons.facebook;
        iconColor = const Color(0xFF1877f2);
        break;
      case WebsiteCategory.twitter:
        iconData = FontAwesomeIcons.twitter;
        iconColor = const Color(0xFF1da1f2);
        break;
      case WebsiteCategory.twitch:
        iconData = FontAwesomeIcons.twitch;
        iconColor = const Color(0xFF9146ff);
        break;
      case WebsiteCategory.instagram:
        iconData = FontAwesomeIcons.instagram;
        iconColor = const Color(0xFFc13584);
        break;
      case WebsiteCategory.youtube:
        iconData = FontAwesomeIcons.youtube;
        iconColor = const Color(0xFFff0000);
        break;
      case WebsiteCategory.iphone:
        iconData = FontAwesomeIcons.apple;
        iconColor = const Color(0xFF000000);
        break;
      case WebsiteCategory.ipad:
        iconData = FontAwesomeIcons.apple;
        iconColor = const Color(0xFF000000);
        break;
      case WebsiteCategory.android:
        iconData = FontAwesomeIcons.android;
        iconColor = const Color(0xFFa4c639);
        break;
      case WebsiteCategory.steam:
        iconData = FontAwesomeIcons.steam;
        iconColor = const Color(0xFF00adee);
        break;
      case WebsiteCategory.reddit:
        iconData = FontAwesomeIcons.reddit;
        iconColor = const Color(0xFFff4500);
        break;
      case WebsiteCategory.itch:
        iconData = FontAwesomeIcons.itchIo;
        iconColor = const Color(0xFFfa5c5c);
        break;
      case WebsiteCategory.epicgames:
        iconData = FontAwesomeIcons.earlybirds;
        iconColor = const Color(0xFF242424);
        break;
      case WebsiteCategory.gog:
        iconData = FontAwesomeIcons.galacticRepublic;
        iconColor = const Color(0xFF7cb4dc);
        break;
      case WebsiteCategory.discord:
        iconData = FontAwesomeIcons.discord;
        iconColor = const Color(0xFF5865f2);
        break;
      default:
        iconData = Icons.link;
        iconColor = const Color(0xFF07355A);
    }

    return Icon(iconData, color: iconColor, size: 20);
  }

  Color _getWebsiteColor(WebsiteCategory category) {
    switch (category) {
      case WebsiteCategory.official:
        return Colors.blue;
      case WebsiteCategory.wikia:
      case WebsiteCategory.wikipedia:
        return Colors.orange;
      case WebsiteCategory.facebook:
        return const Color(0xFF1877F2);
      case WebsiteCategory.twitter:
        return Colors.black;
      case WebsiteCategory.instagram:
        return const Color(0xFFE4405F);
      case WebsiteCategory.youtube:
        return const Color(0xFFFF0000);
      case WebsiteCategory.twitch:
        return const Color(0xFF9146FF);
      case WebsiteCategory.reddit:
        return const Color(0xFFFF4500);
      case WebsiteCategory.discord:
        return const Color(0xFF5865F2);
      case WebsiteCategory.steam:
        return const Color(0xFF1B2838);
      case WebsiteCategory.epicgames:
        return const Color(0xFF0078F2);
      case WebsiteCategory.gog:
        return const Color(0xFF8A2BE2);
      case WebsiteCategory.itch:
        return const Color(0xFFFA5C5C);
      case WebsiteCategory.iphone:
      case WebsiteCategory.ipad:
        return const Color(0xFF007AFF);
      case WebsiteCategory.android:
        return const Color(0xFF3DDC84);
      case WebsiteCategory.bluesky:
        return const Color(0xFF0085FF);
    }
  }

  // ===== STORE HELPER METHODS =====
  String _getStoreName(ExternalGameCategoryEnum? category) {
    if (category == null) return 'Store';

    switch (category) {
      case ExternalGameCategoryEnum.steam:
        return 'Steam';
      case ExternalGameCategoryEnum.gog:
        return 'GOG';
      case ExternalGameCategoryEnum.epicGameStore:
        return 'Epic Games Store';
      case ExternalGameCategoryEnum.playstationStoreUs:
        return 'PlayStation Store';
      case ExternalGameCategoryEnum.xboxMarketplace:
        return 'Xbox Marketplace';
      case ExternalGameCategoryEnum.microsoft:
        return 'Microsoft Store';
      case ExternalGameCategoryEnum.apple:
        return 'App Store';
      case ExternalGameCategoryEnum.android:
        return 'Google Play';
      case ExternalGameCategoryEnum.itchIo:
        return 'itch.io';
      case ExternalGameCategoryEnum.amazonLuna:
        return 'Amazon Luna';
      case ExternalGameCategoryEnum.oculus:
        return 'Oculus Store';
      case ExternalGameCategoryEnum.twitch:
        return 'Twitch';
      case ExternalGameCategoryEnum.youtube:
        return 'YouTube';
      default:
        return category.displayName;
    }
  }

  IconData _getStoreIcon(ExternalGameCategoryEnum? category) {
    if (category == null) return Icons.store;

    switch (category) {
      case ExternalGameCategoryEnum.steam:
        return FontAwesomeIcons.steam;
      case ExternalGameCategoryEnum.gog:
        return FontAwesomeIcons.galacticRepublic;
      case ExternalGameCategoryEnum.epicGameStore:
        return FontAwesomeIcons.gamepad;
      case ExternalGameCategoryEnum.playstationStoreUs:
        return FontAwesomeIcons.playstation;
      case ExternalGameCategoryEnum.xboxMarketplace:
        return FontAwesomeIcons.xbox;
      case ExternalGameCategoryEnum.microsoft:
        return FontAwesomeIcons.xbox;
      case ExternalGameCategoryEnum.apple:
        return FontAwesomeIcons.apple;
      case ExternalGameCategoryEnum.android:
        return FontAwesomeIcons.android;
      case ExternalGameCategoryEnum.itchIo:
        return FontAwesomeIcons.itchIo;
      case ExternalGameCategoryEnum.amazonLuna:
        return FontAwesomeIcons.amazon;
      case ExternalGameCategoryEnum.amazonAdg:
        return FontAwesomeIcons.amazon;
      case ExternalGameCategoryEnum.amazonAsin:
        return FontAwesomeIcons.amazon;
      case ExternalGameCategoryEnum.oculus:
        return FontAwesomeIcons.vrCardboard;
      case ExternalGameCategoryEnum.twitch:
        return FontAwesomeIcons.twitch;
      case ExternalGameCategoryEnum.youtube:
        return FontAwesomeIcons.youtube;
      default:
        return Icons.store;
    }
  }

  Color _getStoreColor(
      BuildContext context, ExternalGameCategoryEnum? category) {
    if (category == null) return Theme.of(context).colorScheme.primary;

    switch (category) {
      case ExternalGameCategoryEnum.steam:
        return const Color(0xFF1B2838);
      case ExternalGameCategoryEnum.gog:
        return const Color(0xFF8A2BE2);
      case ExternalGameCategoryEnum.epicGameStore:
        return const Color(0xFF0078F2);
      case ExternalGameCategoryEnum.playstationStoreUs:
        return const Color(0xFF0070D1);
      case ExternalGameCategoryEnum.xboxMarketplace:
        return const Color(0xFF107C10);
      case ExternalGameCategoryEnum.microsoft:
        return const Color(0xFF00BCF2);
      case ExternalGameCategoryEnum.apple:
        return const Color(0xFF007AFF);
      case ExternalGameCategoryEnum.android:
        return const Color(0xFF3DDC84);
      case ExternalGameCategoryEnum.itchIo:
        return const Color(0xFFFA5C5C);
      case ExternalGameCategoryEnum.amazonLuna:
        return const Color(0xFFFF9900);
      case ExternalGameCategoryEnum.oculus:
        return const Color(0xFF1C1E20);
      case ExternalGameCategoryEnum.twitch:
        return const Color(0xFF9146FF);
      case ExternalGameCategoryEnum.youtube:
        return const Color(0xFFFF0000);
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
      // Generate store URL based on category and game ID
      String? url = _generateStoreUrl(store);
      if (url != null) {
        await _launchUrl(url);
      }
    } catch (e) {
      print('Error launching store URL: $e');
    }
  }

  String? _generateStoreUrl(ExternalGame store) {
    // This would depend on your ExternalGame structure
    // For now, return null if no URL available
    if (store.url != null && store.url!.isNotEmpty) {
      return store.url;
    }

    // Generate URLs based on store ID and category if needed
    // e.g., Steam: https://store.steampowered.com/app/${store.externalId}
    return null;
  }
}
