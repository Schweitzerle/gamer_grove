// ==================================================
// COMMUNITY INFO SECTION - ACCORDION VERSION
// ==================================================

// lib/presentation/pages/game_detail/widgets/community_info_section.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/game.dart';

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
                        'Community Info',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      // Quick Info Preview (when collapsed)
                      if (!_isExpanded) _buildInfoPreview(),

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
                child: Row(
                  children: [
                    // IGDB Rating
                    if (widget.game.rating != null)
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.star,
                          label: 'IGDB Rating',
                          value: '${widget.game.rating!.toStringAsFixed(1)}/10',
                          color: ColorScales.getRatingColor(widget.game.rating!),
                        ),
                      ),

                    if (widget.game.rating != null && widget.game.releaseDate != null)
                      const SizedBox(width: 8),

                    // Release Date
                    if (widget.game.releaseDate != null)
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.calendar_today,
                          label: 'Release Date',
                          value: DateFormatter.formatShortDate(widget.game.releaseDate!),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
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

  // ✅ Info Preview für collapsed state
  Widget _buildInfoPreview() {
    List<String> info = [];

    if (widget.game.rating != null) {
      info.add('⭐${widget.game.rating!.toStringAsFixed(1)}');
    }

    if (widget.game.releaseDate != null) {
      info.add('📅${DateFormatter.formatYearOnly(widget.game.releaseDate!)}');
    }

    return Text(
      info.join(' • '),
      style: TextStyle(
        fontSize: 10,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.onColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(height: 6),

          // Label
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 3),

          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.lighten(20),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}




