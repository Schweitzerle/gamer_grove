// ==================================================
// EXTERNAL LINKS SECTION - HORIZONTAL VERSION (FIXED)
// ==================================================

// lib/presentation/pages/game_detail/widgets/sections/external_links_section.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_constants.dart';
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
    final hasWebsites = game.websites.isNotEmpty;
    final hasStores = game.externalGames.isNotEmpty;

    if (!hasWebsites && !hasStores) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Official Websites
        if (hasWebsites) ...[
          _buildSectionHeader(
            context,
            'Official Links',
            game.websites.length,
            Icons.link,
          ),
          const SizedBox(height: 12),
          WebsiteLinksRow(websites: game.websites),
          if (hasStores) const SizedBox(height: 24),
        ],

        // External Stores
        if (hasStores) ...[
          _buildSectionHeader(
            context,
            'Available On',
            game.externalGames.length,
            Icons.store,
          ),
          const SizedBox(height: 12),
          StoreLinksSection(stores: game.externalGames),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context,
      String title,
      int count,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
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
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================
// WEBSITE LINKS ROW
// ==================================================

class WebsiteLinksRow extends StatelessWidget {
  final List<Website> websites;

  const WebsiteLinksRow({
    super.key,
    required this.websites,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: websites
          .map((website) => WebsiteLinkButton(website: website))
          .toList(),
    );
  }
}

class WebsiteLinkButton extends StatelessWidget {
  final Website website;

  const WebsiteLinkButton({
    super.key,
    required this.website,
  });

  @override
  Widget build(BuildContext context) {
    final websiteInfo = _getWebsiteInfo(website.category);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: websiteInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: websiteInfo.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _launchUrl(website.url),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                websiteInfo.icon,
                color: websiteInfo.color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                websiteInfo.shortName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: websiteInfo.color,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  WebsiteInfo _getWebsiteInfo(WebsiteCategory category) {
    switch (category) {
      case WebsiteCategory.official:
        return WebsiteInfo('Web', Icons.language, Colors.blue);
      case WebsiteCategory.wikia:
        return WebsiteInfo('Wiki', Icons.menu_book, Colors.orange);
      case WebsiteCategory.wikipedia:
        return WebsiteInfo('Wiki', Icons.article, Colors.grey);
      case WebsiteCategory.facebook:
        return WebsiteInfo('FB', Icons.facebook, const Color(0xFF1877F2));
      case WebsiteCategory.twitter:
        return WebsiteInfo('X', Icons.alternate_email, Colors.black);
      case WebsiteCategory.twitch:
        return WebsiteInfo('Twitch', Icons.live_tv, const Color(0xFF9146FF));
      case WebsiteCategory.instagram:
        return WebsiteInfo('IG', Icons.camera_alt, const Color(0xFFE4405F));
      case WebsiteCategory.youtube:
        return WebsiteInfo('YT', Icons.play_circle_fill, const Color(0xFFFF0000));
      case WebsiteCategory.reddit:
        return WebsiteInfo('Reddit', Icons.forum, const Color(0xFFFF4500));
      case WebsiteCategory.discord:
        return WebsiteInfo('Discord', Icons.chat, const Color(0xFF5865F2));
      default:
        return WebsiteInfo('Link', Icons.link, Colors.grey);
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }
}

class WebsiteInfo {
  final String shortName;
  final IconData icon;
  final Color color;

  WebsiteInfo(this.shortName, this.icon, this.color);
}

// ==================================================
// STORE LINKS SECTION (FIXED)
// ==================================================

class StoreLinksSection extends StatelessWidget {
  final List<ExternalGame> stores;

  const StoreLinksSection({
    super.key,
    required this.stores,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stores.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < stores.length - 1 ? 12 : 0,
            ),
            child: StoreLinkCard(store: stores[index]),
          );
        },
      ),
    );
  }
}

class StoreLinkCard extends StatelessWidget {
  final ExternalGame store;

  const StoreLinkCard({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    // FIXED: Verwende categoryEnum statt category
    final storeInfo = _getStoreInfo(store.categoryEnum);

    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: storeInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: storeInfo.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          // FIXED: Verwende storeUrl getter statt direkten url
          onTap: store.storeUrl != null ? () => _launchUrl(store.storeUrl!) : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Store Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: storeInfo.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    storeInfo.icon,
                    color: storeInfo.color,
                    size: 20,
                  ),
                ),

                const SizedBox(height: 6),

                // Store Name
                Text(
                  storeInfo.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: storeInfo.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
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

  // FIXED: Parameter type changed to ExternalGameCategoryEnum?
  StoreInfo _getStoreInfo(ExternalGameCategoryEnum? category) {
    if (category == null) {
      return StoreInfo('Store', Icons.store, Colors.grey);
    }

    switch (category) {
      case ExternalGameCategoryEnum.steam: // FIXED: Correct enum reference
        return StoreInfo('Steam', Icons.games, const Color(0xFF1B2838));
      case ExternalGameCategoryEnum.gog:
        return StoreInfo('GOG', Icons.shopping_bag, const Color(0xFF8A2BE2));
      case ExternalGameCategoryEnum.epicGameStore:
        return StoreInfo('Epic', Icons.rocket_launch, const Color(0xFF0078F2));
      case ExternalGameCategoryEnum.playstationStoreUs:
        return StoreInfo('PlayStation', Icons.sports_esports, const Color(0xFF0070D1));
      case ExternalGameCategoryEnum.xboxMarketplace:
        return StoreInfo('Xbox', Icons.gamepad, const Color(0xFF107C10));
      case ExternalGameCategoryEnum.microsoft:
        return StoreInfo('Microsoft', Icons.window, const Color(0xFF00BCF2));
      case ExternalGameCategoryEnum.apple:
        return StoreInfo('App Store', Icons.phone_iphone, const Color(0xFF007AFF));
      case ExternalGameCategoryEnum.android:
        return StoreInfo('Google Play', Icons.android, const Color(0xFF3DDC84));
      case ExternalGameCategoryEnum.itchIo:
        return StoreInfo('itch.io', Icons.videogame_asset, const Color(0xFFFA5C5C));
      case ExternalGameCategoryEnum.amazonLuna:
        return StoreInfo('Luna', Icons.cloud_queue, const Color(0xFFFF9900));
      case ExternalGameCategoryEnum.oculus:
        return StoreInfo('Oculus', Icons.view_in_ar, const Color(0xFF1C1E20));
      case ExternalGameCategoryEnum.twitch:
        return StoreInfo('Twitch', Icons.live_tv, const Color(0xFF9146FF));
      case ExternalGameCategoryEnum.youtube:
        return StoreInfo('YouTube', Icons.play_circle_fill, const Color(0xFFFF0000));
      default:
        return StoreInfo(category.displayName, Icons.store, Colors.grey);
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      // Handle error silently or show snackbar
      print('Could not launch $url: $e');
    }
  }
}

class StoreInfo {
  final String name;
  final IconData icon;
  final Color color;

  StoreInfo(this.name, this.icon, this.color);
}