// ==================================================
// DLC & EXPANSION SECTION
// ==================================================

// lib/presentation/pages/game_detail/widgets/dlc_expansion_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/game.dart';
import '../game_detail_page.dart';

class DLCExpansionSection extends StatelessWidget {
  final List<Game> dlcs;
  final List<Game> expansions;

  const DLCExpansionSection({
    super.key,
    required this.dlcs,
    required this.expansions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Content',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          if (expansions.isNotEmpty) ...[
            Text(
              'Expansions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...expansions.map((expansion) => _buildContentTile(context, expansion, 'Expansion')),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          if (dlcs.isNotEmpty) ...[
            Text(
              'DLCs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...dlcs.map((dlc) => _buildContentTile(context, dlc, 'DLC')),
          ],
        ],
      ),
    );
  }

  Widget _buildContentTile(BuildContext context, Game content, String type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedImageWidget(
            imageUrl: ImageUtils.getSmallImageUrl(content.coverUrl),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(content.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type),
            if (content.releaseDate != null)
              Text(DateFormatter.formatShortDate(content.releaseDate!)),
          ],
        ),
        trailing: content.rating != null
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                content.rating!.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
            : null,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameDetailPage(gameId: content.id),
            ),
          );
        },
      ),
    );
  }
}