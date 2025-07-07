// lib/presentation/pages/game_detail/widgets/sections/age_ratings_section.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/ageRating/age_rating.dart';
import '../../../domain/entities/ageRating/age_rating_organization.dart';

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
          height: 70, // Etwas höher für bessere Darstellung
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
    // VERBESSERT: Verwende die Helper-Getter der AgeRating Entity
    final ratingStyle = _getRatingStyleFromEntity(rating);

    return GestureDetector(
      onTap: () => _showRatingDetails(context, rating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ratingStyle.color.withOpacity(0.1),
              ratingStyle.color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: ratingStyle.color, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ratingStyle.color.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ratingStyle.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                  ratingStyle.icon,
                  color: ratingStyle.color,
                  size: 20
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating.displayName,
                  style: TextStyle(
                    color: ratingStyle.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  ratingStyle.organizationName,
                  style: TextStyle(
                    color: ratingStyle.color.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// VERBESSERT: Bestimme Rating Style basierend auf AgeRating Entity Helper-Gettern
  _RatingStyle _getRatingStyleFromEntity(AgeRating rating) {
    // Verwende die Helper-Getter die sowohl organization als auch categoryEnum berücksichtigen
    if (rating.isESRB) {
      return _RatingStyle(
        color: const Color(0xFF1976D2), // Schönes Blau
        icon: Icons.flag_rounded,
        organizationName: 'ESRB',
      );
    } else if (rating.isPEGI) {
      return _RatingStyle(
        color: const Color(0xFF388E3C), // Schönes Grün
        icon: Icons.euro_symbol_rounded,
        organizationName: 'PEGI',
      );
    } else if (rating.isCERO) {
      return _RatingStyle(
        color: const Color(0xFFD32F2F), // Schönes Rot
        icon: Icons.place_rounded,
        organizationName: 'CERO',
      );
    } else if (rating.isUSK) {
      return _RatingStyle(
        color: const Color(0xFFFF8F00), // Schönes Orange
        icon: Icons.shield_rounded,
        organizationName: 'USK',
      );
    } else if (rating.isGRAC) {
      return _RatingStyle(
        color: const Color(0xFF7B1FA2), // Schönes Lila
        icon: Icons.star_rounded,
        organizationName: 'GRAC',
      );
    } else if (rating.isClassInd) {
      return _RatingStyle(
        color: const Color(0xFF00796B), // Schönes Teal
        icon: Icons.info_rounded,
        organizationName: 'ClassInd',
      );
    } else if (rating.isACB) {
      return _RatingStyle(
        color: const Color(0xFF303F9F), // Schönes Indigo
        icon: Icons.public_rounded,
        organizationName: 'ACB',
      );
    } else {
      // Fallback - zeige trotzdem schön an auch wenn unbekannt
      return _RatingStyle(
        color: const Color(0xFF757575), // Neutrales Grau
        icon: Icons.sports_esports_rounded,
        organizationName: rating.organizationName.isNotEmpty
            ? rating.organizationName
            : 'Rating',
      );
    }
  }

  /// Zeigt Details zum Age Rating in einem Dialog
  void _showRatingDetails(BuildContext context, AgeRating rating) {
    if (rating.synopsis != null ||
        rating.contentDescriptions.isNotEmpty ||
        rating.ratingCoverUrl != null) {
      showDialog(
        context: context,
        builder: (context) => AgeRatingDetailsDialog(rating: rating),
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
    final ratingStyle = _getRatingStyleFromEntity(rating);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ratingStyle.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              ratingStyle.icon,
              color: ratingStyle.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating.displayName,
                  style: TextStyle(
                    color: ratingStyle.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ratingStyle.organizationName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ratingStyle.color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Synopsis
            if (rating.synopsis != null) ...[
              _buildSectionTitle(context, 'Description'),
              const SizedBox(height: 8),
              Text(
                rating.synopsis!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],

            // Content Descriptions
            if (rating.contentDescriptions.isNotEmpty) ...[
              _buildSectionTitle(context, 'Content Descriptors'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: rating.contentDescriptions.map((desc) =>
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6
                      ),
                      decoration: BoxDecoration(
                        color: ratingStyle.color.withOpacity(0.1),
                        border: Border.all(
                          color: ratingStyle.color.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        desc.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: ratingStyle.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Rating Cover Image
            if (rating.ratingCoverUrl != null) ...[
              _buildSectionTitle(context, 'Rating Image'),
              const SizedBox(height: 8),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ratingStyle.color.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.network(
                      rating.ratingCoverUrl!,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: ratingStyle.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: ratingStyle.color,
                              size: 40,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: ratingStyle.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  /// Bestimme Rating Style (gleiche Logik wie in AgeRatingChip)
  _RatingStyle _getRatingStyleFromEntity(AgeRating rating) {
    if (rating.isESRB) {
      return _RatingStyle(
        color: const Color(0xFF1976D2),
        icon: Icons.flag_rounded,
        organizationName: 'ESRB',
      );
    } else if (rating.isPEGI) {
      return _RatingStyle(
        color: const Color(0xFF388E3C),
        icon: Icons.euro_symbol_rounded,
        organizationName: 'PEGI',
      );
    } else if (rating.isCERO) {
      return _RatingStyle(
        color: const Color(0xFFD32F2F),
        icon: Icons.place_rounded,
        organizationName: 'CERO',
      );
    } else if (rating.isUSK) {
      return _RatingStyle(
        color: const Color(0xFFFF8F00),
        icon: Icons.shield_rounded,
        organizationName: 'USK',
      );
    } else if (rating.isGRAC) {
      return _RatingStyle(
        color: const Color(0xFF7B1FA2),
        icon: Icons.star_rounded,
        organizationName: 'GRAC',
      );
    } else if (rating.isClassInd) {
      return _RatingStyle(
        color: const Color(0xFF00796B),
        icon: Icons.info_rounded,
        organizationName: 'ClassInd',
      );
    } else if (rating.isACB) {
      return _RatingStyle(
        color: const Color(0xFF303F9F),
        icon: Icons.public_rounded,
        organizationName: 'ACB',
      );
    } else {
      return _RatingStyle(
        color: const Color(0xFF757575),
        icon: Icons.sports_esports_rounded,
        organizationName: rating.organizationName.isNotEmpty
            ? rating.organizationName
            : 'Rating',
      );
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
  String? selectedOrganization;

  @override
  Widget build(BuildContext context) {
    if (widget.ageRatings.isEmpty) {
      return const SizedBox.shrink();
    }

    final filteredRatings = selectedOrganization != null
        ? widget.ageRatings.where((r) =>
    r.organizationName.toLowerCase() == selectedOrganization!.toLowerCase()
    ).toList()
        : widget.ageRatings;

    final availableOrganizations = widget.ageRatings
        .map((r) => r.organizationName)
        .where((name) => name.isNotEmpty && name != 'Unknown')
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String?>(
                  value: selectedOrganization,
                  hint: const Text('All'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All'),
                    ),
                    ...availableOrganizations.map((org) =>
                        DropdownMenuItem<String?>(
                          value: org,
                          child: Text(org.toUpperCase()),
                        ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedOrganization = value;
                    });
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Age Rating Chips
        SizedBox(
          height: 70,
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