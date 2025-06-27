// ==================================================
// AGE RATINGS SECTION (AKTUALISIERT FÜR ERWEITERTE API)
// ==================================================

// lib/presentation/pages/game_detail/widgets/sections/age_ratings_section.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/ageRating/age_rating.dart';

class AgeRatingsSection extends StatelessWidget {
  final List<AgeRating> ageRatings;

  const AgeRatingsSection({
    super.key,
    required this.ageRatings,
  });

  @override
  Widget build(BuildContext context) {
    if (ageRatings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age Ratings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ageRatings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AgeRatingChip(rating: ageRatings[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AgeRatingChip extends StatelessWidget {
  final AgeRating rating;

  const AgeRatingChip({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final ratingStyle = _getRatingStyle(rating.organization);

    return GestureDetector(
      onTap: () => _showRatingDetails(context, rating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ratingStyle.color.withOpacity(0.1),
          border: Border.all(color: ratingStyle.color, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ratingStyle.icon, color: ratingStyle.color, size: 20),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating.displayName,
                  style: TextStyle(
                    color: ratingStyle.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  ratingStyle.organizationName,
                  style: TextStyle(
                    color: ratingStyle.color.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Zeigt Details zum Age Rating in einem Dialog
  void _showRatingDetails(BuildContext context, AgeRating rating) {
    if (rating.synopsis != null || rating.contentDescriptions.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AgeRatingDetailsDialog(rating: rating),
      );
    }
  }

  /// Gibt Styling-Informationen für eine Organisation zurück
  _RatingStyle _getRatingStyle(AgeRatingOrganization organization) {
    switch (organization) {
      case AgeRatingOrganization.esrb:
        return _RatingStyle(
          color: Colors.blue,
          icon: Icons.flag,
          organizationName: 'ESRB',
        );
      case AgeRatingOrganization.pegi:
        return _RatingStyle(
          color: Colors.green,
          icon: Icons.euro,
          organizationName: 'PEGI',
        );
      case AgeRatingOrganization.cero:
        return _RatingStyle(
          color: Colors.red,
          icon: Icons.location_on,
          organizationName: 'CERO',
        );
      case AgeRatingOrganization.usk:
        return _RatingStyle(
          color: Colors.orange,
          icon: Icons.shield,
          organizationName: 'USK',
        );
      case AgeRatingOrganization.grac:
        return _RatingStyle(
          color: Colors.purple,
          icon: Icons.star,
          organizationName: 'GRAC',
        );
      case AgeRatingOrganization.classInd:
        return _RatingStyle(
          color: Colors.teal,
          icon: Icons.info,
          organizationName: 'CLASS IND',
        );
      case AgeRatingOrganization.acb:
        return _RatingStyle(
          color: Colors.indigo,
          icon: Icons.public,
          organizationName: 'ACB',
        );
      default:
        return _RatingStyle(
          color: Colors.grey,
          icon: Icons.help,
          organizationName: 'UNKNOWN',
        );
    }
  }
}

/// Style-Klasse für Age Rating Darstellung
class _RatingStyle {
  final Color color;
  final IconData icon;
  final String organizationName;

  const _RatingStyle({
    required this.color,
    required this.icon,
    required this.organizationName,
  });
}

/// Dialog für detaillierte Age Rating Informationen
class AgeRatingDetailsDialog extends StatelessWidget {
  final AgeRating rating;

  const AgeRatingDetailsDialog({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_getRatingIcon(rating.organization)),
          const SizedBox(width: 8),
          Text(rating.displayName),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Synopsis
            if (rating.synopsis != null) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(rating.synopsis!),
              const SizedBox(height: 16),
            ],

            // Content Descriptions
            if (rating.contentDescriptions.isNotEmpty) ...[
              Text(
                'Content Descriptors',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: rating.contentDescriptions.map((desc) =>
                    Chip(
                      label: Text(
                        desc,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                ).toList(),
              ),
            ],

            // Rating Cover Image
            if (rating.ratingCoverUrl != null) ...[
              const SizedBox(height: 16),
              Text(
                'Rating Image',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  rating.ratingCoverUrl!,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  IconData _getRatingIcon(AgeRatingOrganization organization) {
    switch (organization) {
      case AgeRatingOrganization.esrb: return Icons.flag;
      case AgeRatingOrganization.pegi: return Icons.euro;
      case AgeRatingOrganization.cero: return Icons.location_on;
      case AgeRatingOrganization.usk: return Icons.shield;
      case AgeRatingOrganization.grac: return Icons.star;
      case AgeRatingOrganization.classInd: return Icons.info;
      case AgeRatingOrganization.acb: return Icons.public;
      default: return Icons.help;
    }
  }
}

/// Erweiterte Age Ratings Section mit Filter-Funktionalität
class EnhancedAgeRatingsSection extends StatefulWidget {
  final List<AgeRating> ageRatings;
  final bool showAllRatings;

  const EnhancedAgeRatingsSection({
    super.key,
    required this.ageRatings,
    this.showAllRatings = false,
  });

  @override
  State<EnhancedAgeRatingsSection> createState() => _EnhancedAgeRatingsSectionState();
}

class _EnhancedAgeRatingsSectionState extends State<EnhancedAgeRatingsSection> {
  AgeRatingOrganization? selectedOrganization;

  @override
  Widget build(BuildContext context) {
    if (widget.ageRatings.isEmpty) {
      return const SizedBox.shrink();
    }

    final filteredRatings = selectedOrganization != null
        ? widget.ageRatings.where((r) => r.organization == selectedOrganization).toList()
        : widget.ageRatings;

    final availableOrganizations = widget.ageRatings
        .map((r) => r.organization)
        .toSet()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header mit Filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Age Ratings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (availableOrganizations.length > 1)
              DropdownButton<AgeRatingOrganization?>(
                value: selectedOrganization,
                hint: const Text('All'),
                items: [
                  const DropdownMenuItem<AgeRatingOrganization?>(
                    value: null,
                    child: Text('All'),
                  ),
                  ...availableOrganizations.map((org) =>
                      DropdownMenuItem<AgeRatingOrganization?>(
                        value: org,
                        child: Text(org.name.toUpperCase()),
                      ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedOrganization = value;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Age Rating Chips
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredRatings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AgeRatingChip(rating: filteredRatings[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}