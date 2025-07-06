// ==================================================
// FIXED PLATFORM & RELEASE SECTION - ROBUST GEGEN NULL-WERTE
// ==================================================

// lib/presentation/widgets/sections/fixed_platform_release_section.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../domain/entities/releaseDate/release_date.dart';

class PlatformReleaseSection extends StatelessWidget {
  final Game game;

  const PlatformReleaseSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    // Debug Print
    print('🔧 FixedPlatformReleaseSection: Building with ${game.platforms.length} platforms');

    // Group release dates by platform
    final platformReleases = _groupReleasesByPlatform();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ PLATFORM CARDS SECTION
        if (game.platforms.isNotEmpty) ...[
          _buildPlatformCardsSection(context, platformReleases),
        ],

        // ✅ RELEASE TIMELINE SECTION
        if (game.releaseDates.isNotEmpty) ...[
          if (game.platforms.isNotEmpty) const SizedBox(height: 24),
          _buildReleaseTimelineSection(context),
        ],

        // ✅ FIRST RELEASE INFO
        if (game.firstReleaseDate != null) ...[
          const SizedBox(height: 16),
          _buildFirstReleaseInfo(context),
        ],
      ],
    );
  }

  // ✅ PLATFORM CARDS SECTION
  Widget _buildPlatformCardsSection(BuildContext context, Map<int, List<ReleaseDate>> platformReleases) {
    print('🔧 Building platform cards section with ${game.platforms.length} platforms');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.devices,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Available Platforms',
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
                '${game.platforms.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Platform Cards Horizontal List
        SizedBox(
          height: 200, // Fixed height for cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: game.platforms.length,
            itemBuilder: (context, index) {
              print('🔧 Building platform card $index: ${game.platforms[index].name}');
              final platform = game.platforms[index];
              final releases = platformReleases[platform.id] ?? [];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < game.platforms.length - 1 ? 12 : 0,
                ),
                child: _buildPlatformCard(context, platform, releases),
              );
            },
          ),
        ),
      ],
    );
  }

  // ✅ PLATFORM CARD WIDGET - SIMPLIFIED & ROBUST
  Widget _buildPlatformCard(BuildContext context, Platform platform, List<ReleaseDate> releases) {
    print('🔧 Building card for platform: ${platform.name} (ID: ${platform.id})');

    final earliestRelease = releases.isNotEmpty
        ? releases.reduce((a, b) => (a.date?.millisecondsSinceEpoch ?? 0) < (b.date?.millisecondsSinceEpoch ?? 0) ? a : b)
        : null;

    final platformColor = _getPlatformColor(platform.name);
    final platformIcon = _getPlatformIcon(platform.name);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: platformColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: platformColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Platform Logo/Icon - SIMPLIFIED
          Container(
            height: 60,
            width: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: platformColor.withValues(alpha: 0.2),
              ),
            ),
            child: platform.logoUrl != null && platform.logoUrl!.isNotEmpty
                ? CachedImageWidget(
              imageUrl: platform.logoUrl!,
              fit: BoxFit.contain,
              errorWidget: Icon(
                _getPlatformIcon(platform.name),
                color: platformColor,
                size: 24,
              ),
            )
                : Icon(
              _getPlatformIcon(platform.name),
              color: platformColor,
              size: 24,
            ),
          ),

          const SizedBox(height: 8),

          // Platform Name - SAFE
          Text(
            _getSafePlatformName(platform),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: platformColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Platform Category - SAFE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: platformColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getSafePlatformCategory(platform),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: platformColor,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Release Date (if available) - SAFE
          if (earliestRelease?.date != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: platformColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: platformColor,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatShortDate(earliestRelease!.date!),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: platformColor,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Fallback for no release date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Release TBD',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ],

          // Multiple regions indicator
          if (releases.length > 1) ...[
            const SizedBox(height: 4),
            Text(
              '${releases.length} releases',
              style: TextStyle(
                fontSize: 9,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ RELEASE TIMELINE SECTION
  Widget _buildReleaseTimelineSection(BuildContext context) {
    // Group releases by date
    final releasesGrouped = <String, List<ReleaseDate>>{};

    for (final release in game.releaseDates) {
      if (release.date != null) {
        final dateKey = DateFormatter.formatShortDate(release.date!);
        releasesGrouped[dateKey] = (releasesGrouped[dateKey] ?? [])..add(release);
      }
    }

    final sortedDates = releasesGrouped.keys.toList()
      ..sort((a, b) {
        final releaseA = releasesGrouped[a]!.first;
        final releaseB = releasesGrouped[b]!.first;
        return releaseA.date!.compareTo(releaseB.date!);
      });

    if (sortedDates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.timeline,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Release Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Timeline
        Column(
          children: sortedDates.asMap().entries.map((entry) {
            final isLast = entry.key == sortedDates.length - 1;
            final dateKey = entry.value;
            final releases = releasesGrouped[dateKey]!;

            return _buildTimelineItem(context, releases, isLast);
          }).toList(),
        ),
      ],
    );
  }

  // ✅ TIMELINE ITEM
  Widget _buildTimelineItem(BuildContext context, List<ReleaseDate> releases, bool isLast) {
    final firstRelease = releases.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Timeline content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  firstRelease.human ?? DateFormatter.formatFullDate(firstRelease.date!),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 4),

                // Platforms and regions
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: releases.map((release) {
                    final platform = _findPlatformById(release.platformId);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPlatformIcon(platform.name),
                            size: 12,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getSafePlatformName(platform),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                          Text(
                            ' (${_formatRegion(release.regionDisplayName)})',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ FIRST RELEASE INFO
  Widget _buildFirstReleaseInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.rocket_launch,
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
                  'First Release',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatFullDate(game.firstReleaseDate!),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ SAFE HELPER METHODS

  Map<int, List<ReleaseDate>> _groupReleasesByPlatform() {
    final Map<int, List<ReleaseDate>> grouped = {};

    for (final release in game.releaseDates) {
      if (release.platformId != null) {
        grouped[release.platformId!] = (grouped[release.platformId!] ?? [])..add(release);
      }
    }

    return grouped;
  }

  Platform _findPlatformById(int? platformId) {
    if (platformId == null) {
      return Platform(id: 0, name: 'Unknown', abbreviation: null, slug: '', checksum: '');
    }

    try {
      return game.platforms.firstWhere((p) => p.id == platformId);
    } catch (e) {
      return Platform(id: 0, name: 'Unknown', abbreviation: null, slug: '', checksum: '');
    }
  }

  String _getSafePlatformName(Platform platform) {
    // Try abbreviation first, then name
    if (platform.abbreviation != null && platform.abbreviation!.isNotEmpty) {
      return platform.abbreviation!;
    }
    return platform.name;
  }

  String _getSafePlatformCategory(Platform platform) {
    try {
      // Handle both enum and string categories
      final categoryStr = platform.categoryName;

      // Remove enum prefix if present
      final cleanCategory = categoryStr.contains('.')
          ? categoryStr.split('.').last
          : categoryStr;

      switch (cleanCategory.toLowerCase()) {
        case 'console': return 'Console';
        case 'operatingsystem': return 'PC';
        case 'arcade': return 'Arcade';
        case 'portableconsole': return 'Handheld';
        case 'computer': return 'PC';
        default: return 'Platform';
      }
          return 'Platform';
    } catch (e) {
      print('🔧 Error formatting platform category: $e');
      return 'Platform';
    }
  }

  Color _getPlatformColor(String platformName) {
    final name = platformName.toLowerCase();

    if (name.contains('playstation') || name.contains('ps')) {
      return const Color(0xFF003791); // PlayStation Blue
    } else if (name.contains('xbox')) {
      return const Color(0xFF107C10); // Xbox Green
    } else if (name.contains('steam') || name.contains('pc') || name.contains('microsoft windows')) {
      return const Color(0xFF1B2838); // Steam Dark Blue
    } else if (name.contains('nintendo') || name.contains('switch')) {
      return const Color(0xFFE60012); // Nintendo Red
    } else if (name.contains('ios') || name.contains('iphone')) {
      return const Color(0xFF007AFF); // iOS Blue
    } else if (name.contains('android')) {
      return const Color(0xFF3DDC84); // Android Green
    } else if (name.contains('epic')) {
      return const Color(0xFF313131); // Epic Games
    } else {
      return Colors.blueGrey;
    }
  }

  IconData _getPlatformIcon(String platformName) {
    final name = platformName.toLowerCase();

    if (name.contains('playstation') || name.contains('ps')) {
      return Icons.videogame_asset;
    } else if (name.contains('xbox')) {
      return Icons.sports_esports;
    } else if (name.contains('steam') || name.contains('pc') || name.contains('microsoft windows')) {
      return Icons.computer;
    } else if (name.contains('nintendo') || name.contains('switch')) {
      return Icons.games;
    } else if (name.contains('ios') || name.contains('iphone')) {
      return Icons.phone_iphone;
    } else if (name.contains('android')) {
      return Icons.phone_android;
    } else if (name.contains('mac')) {
      return Icons.laptop_mac;
    } else {
      return Icons.devices;
    }
  }

  String _formatRegion(dynamic region) {
    if (region == null) return 'WW';

    final regionStr = region.toString().toLowerCase();

    if (regionStr.contains('europe')) return 'EU';
    if (regionStr.contains('north_america')) return 'NA';
    if (regionStr.contains('japan')) return 'JP';
    if (regionStr.contains('worldwide')) return 'WW';
    if (regionStr.contains('asia')) return 'AS';
    if (regionStr.contains('china')) return 'CN';
    if (regionStr.contains('korea')) return 'KR';
    if (regionStr.contains('brazil')) return 'BR';
    if (regionStr.contains('australia')) return 'AU';
    if (regionStr.contains('new_zealand')) return 'NZ';

    return 'WW'; // Default fallback
  }
}