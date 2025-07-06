// ==================================================
// ENHANCED COMMUNITY INFO SECTION - ERWEITERTE VERSION
// ==================================================

// lib/presentation/pages/game_detail/widgets/enhanced_community_info_section.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/game/game.dart';

class CommunityInfoSection extends StatefulWidget {
  final Game game;

  const CommunityInfoSection({
    super.key,
    required this.game,
  });

  @override
  State<CommunityInfoSection> createState() => _CommunityInfoSectionState();
}

class _CommunityInfoSectionState extends State<CommunityInfoSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        child: Column(
          children: [
            // ✅ Accordion Header
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Row(
                    children: [
                      // Icon & Title
                      Icon(
                        Icons.public,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Community & Ratings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      // Enhanced Info Preview (when collapsed)
                      if (!_isExpanded) _buildEnhancedInfoPreview(),

                      const SizedBox(width: 8),

                      // Expand/Collapse Icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ Expandable Content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingMedium,
                  0,
                  AppConstants.paddingMedium,
                  AppConstants.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ RATINGS SECTION
                    if (_hasAnyRating()) ...[
                      _buildRatingsSection(context),
                      if (_hasOtherInfo()) const SizedBox(height: 20),
                    ],

                    // ✅ COMMUNITY ENGAGEMENT SECTION
                    if (_hasOtherInfo()) _buildCommunitySection(context),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ RATINGS SECTION
  Widget _buildRatingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Ratings & Reviews',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Ratings Grid
        Row(
          children: [
            // ✅ TOTAL RATING (Combined IGDB + Critics)
            if (widget.game.totalRating != null)
              Expanded(
                child: _buildRatingCard(
                  context,
                  title: 'Overall',
                  rating: widget.game.totalRating!,
                  count: widget.game.totalRatingCount,
                  icon: Icons.star_rounded,
                  color: ColorScales.getRatingColor(widget.game.totalRating!),
                  subtitle: 'Combined Score',
                ),
              ),

            if (widget.game.totalRating != null && _hasOtherRatings())
              const SizedBox(width: 8),

            // ✅ IGDB USER RATING
            if (widget.game.rating != null)
              Expanded(
                child: _buildRatingCard(
                  context,
                  title: 'IGDB Users',
                  rating: widget.game.rating!,
                  count: widget.game.ratingCount,
                  icon: Icons.people,
                  color: ColorScales.getRatingColor(widget.game.rating!),
                  subtitle: 'User Score',
                ),
              ),

            if (widget.game.rating != null && widget.game.aggregatedRating != null)
              const SizedBox(width: 8),

            // ✅ CRITICS RATING
            if (widget.game.aggregatedRating != null)
              Expanded(
                child: _buildRatingCard(
                  context,
                  title: 'Critics',
                  rating: widget.game.aggregatedRating!,
                  count: widget.game.aggregatedRatingCount,
                  icon: Icons.rate_review,
                  color: ColorScales.getRatingColor(widget.game.aggregatedRating!),
                  subtitle: 'Critic Score',
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ✅ COMMUNITY ENGAGEMENT SECTION
  Widget _buildCommunitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.trending_up,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Community Interest',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Community Info Row
        Row(
          children: [
            // ✅ HYPES (Pre-release interest)
            if (widget.game.hypes != null && widget.game.hypes! > 0)
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.favorite,
                  label: 'Pre-Release Hype',
                  value: _formatNumber(widget.game.hypes!),
                  color: Colors.pink,
                ),
              ),

            if (widget.game.hypes != null && widget.game.hypes! > 0 && widget.game.firstReleaseDate != null)
              const SizedBox(width: 8),

            // ✅ RELEASE DATE
            if (widget.game.firstReleaseDate != null)
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Release Date',
                  value: DateFormatter.formatShortDate(widget.game.firstReleaseDate!),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ✅ RATING CARD WIDGET
  Widget _buildRatingCard(
      BuildContext context, {
        required String title,
        required double rating,
        int? count,
        required IconData icon,
        required Color color,
        required String subtitle,
      }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(height: 8),

          // Rating Value
          Text(
            '${rating.toStringAsFixed(1)}/10',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),

          // Count (if available)
          if (count != null && count > 0) ...[
            const SizedBox(height: 2),
            Text(
              '${_formatNumber(count)} ${count == 1 ? 'review' : 'reviews'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // ✅ INFO CARD WIDGET (for non-rating info)
  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(height: 8),

          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 2),

          // Label
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ✅ ENHANCED INFO PREVIEW (collapsed state)
  Widget _buildEnhancedInfoPreview() {
    List<String> info = [];

    // Show highest priority rating
    if (widget.game.totalRating != null) {
      info.add('⭐${widget.game.totalRating!.toStringAsFixed(1)}');
    } else if (widget.game.rating != null) {
      info.add('⭐${widget.game.rating!.toStringAsFixed(1)}');
    } else if (widget.game.aggregatedRating != null) {
      info.add('⭐${widget.game.aggregatedRating!.toStringAsFixed(1)}');
    }

    // Add hypes if significant
    if (widget.game.hypes != null && widget.game.hypes! > 0) {
      info.add('❤️${_formatNumber(widget.game.hypes!)}');
    }

    // Add release date
    if (widget.game.firstReleaseDate != null) {
      info.add('📅${DateFormatter.formatYearOnly(widget.game.firstReleaseDate!)}');
    }

    return Text(
      info.join(' • '),
      style: TextStyle(
        fontSize: 10,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }

  // ✅ HELPER METHODS
  bool _hasAnyRating() {
    return widget.game.totalRating != null ||
        widget.game.rating != null ||
        widget.game.aggregatedRating != null;
  }

  bool _hasOtherRatings() {
    int ratingCount = 0;
    if (widget.game.totalRating != null) ratingCount++;
    if (widget.game.rating != null) ratingCount++;
    if (widget.game.aggregatedRating != null) ratingCount++;
    return ratingCount > 1;
  }

  bool _hasOtherInfo() {
    return (widget.game.hypes != null && widget.game.hypes! > 0) ||
        widget.game.firstReleaseDate != null;
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