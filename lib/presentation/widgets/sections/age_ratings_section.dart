// ==================================================
// AGE RATINGS SECTION
// ==================================================

// lib/presentation/pages/game_detail/widgets/sections/age_ratings_section.dart
import 'package:flutter/material.dart';
import '../../../../../domain/entities/age_rating.dart';

class AgeRatingsSection extends StatelessWidget {
  final List<AgeRating> ageRatings;

  const AgeRatingsSection({
    super.key,
    required this.ageRatings,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    Color chipColor;
    IconData icon;

    switch (rating.category) {
      case AgeRatingCategory.esrb:
        chipColor = Colors.blue;
        icon = Icons.flag;
        break;
      case AgeRatingCategory.pegi:
        chipColor = Colors.green;
        icon = Icons.euro;
        break;
      default:
        chipColor = Colors.grey;
        icon = Icons.public;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor, width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: chipColor, size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rating.displayName,
                style: TextStyle(
                  color: chipColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                rating.category.name.toUpperCase(),
                style: TextStyle(
                  color: chipColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}