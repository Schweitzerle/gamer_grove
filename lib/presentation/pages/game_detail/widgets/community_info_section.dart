// ==================================================
// UPDATED GAME DETAILS ACCORDION - MIT COMMUNITY INFO INTEGRATION
// ==================================================

// lib/presentation/widgets/sections/game_details_accordion.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/game/game.dart';


class CommunityInfoContent extends StatelessWidget {
  final Game game;

  const CommunityInfoContent({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            if (game.totalRating != null)
              Expanded(
                child: _buildRatingCard(
                  context,
                  title: 'Overall',
                  rating: game.totalRating!,
                  count: game.totalRatingCount,
                  icon: Icons.star_rounded,
                  color: ColorScales.getRatingColor(game.totalRating!),
                  subtitle: 'Combined Score',
                ),
              ),

            if (game.totalRating != null && _hasOtherRatings())
              const SizedBox(width: 8),

            // ✅ IGDB USER RATING
            if (game.rating != null)
              Expanded(
                child: _buildRatingCard(
                  context,
                  title: 'IGDB Users',
                  rating: game.rating!,
                  count: game.ratingCount,
                  icon: Icons.people,
                  color: ColorScales.getRatingColor(game.rating!),
                  subtitle: 'User Score',
                ),
              ),

            if (game.rating != null && game.aggregatedRating != null)
              const SizedBox(width: 8),

            // ✅ CRITICS RATING
            if (game.aggregatedRating != null)
              Expanded(
                child: _buildRatingCard(
                  context,
                  title: 'Critics',
                  rating: game.aggregatedRating!,
                  count: game.aggregatedRatingCount,
                  icon: Icons.rate_review,
                  color: ColorScales.getRatingColor(game.aggregatedRating!),
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
            if (game.hypes != null && game.hypes! > 0)
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.favorite,
                  label: 'Pre-Release Hype',
                  value: _formatNumber(game.hypes!),
                  color: Colors.pink,
                ),
              ),

            if (game.hypes != null && game.hypes! > 0 && game.firstReleaseDate != null)
              const SizedBox(width: 8),

            // ✅ RELEASE DATE
            if (game.firstReleaseDate != null)
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Release Date',
                  value: DateFormatter.formatShortDate(game.firstReleaseDate!),
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

  // ✅ HELPER METHODS
  bool _hasAnyRating() {
    return game.totalRating != null ||
        game.rating != null ||
        game.aggregatedRating != null;
  }

  bool _hasOtherRatings() {
    int ratingCount = 0;
    if (game.totalRating != null) ratingCount++;
    if (game.rating != null) ratingCount++;
    if (game.aggregatedRating != null) ratingCount++;
    return ratingCount > 1;
  }

  bool _hasOtherInfo() {
    return (game.hypes != null && game.hypes! > 0) ||
        game.firstReleaseDate != null;
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