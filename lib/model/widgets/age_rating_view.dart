import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:gamer_grove/model/igdb_models/age_rating.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class AgeRatingListUI extends StatelessWidget {
  final List<AgeRating> ageRatings;

  const AgeRatingListUI({Key? key, required this.ageRatings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter age ratings for ESRB, PEGI, and USK
    final filteredAgeRatings = ageRatings.where((ageRating) =>
    ageRating.category == 'ESRB'||
        ageRating.category == 'PEGI' ||
        ageRating.category == 'USK').toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClayContainer(
            spread: 2,
            depth: 60,
            customBorderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                'Age Ratings',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).cardTheme.surfaceTintColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            children: filteredAgeRatings.map((ageRating) => AgeRatingUI(ageRating: ageRating)).toList(),
          ),
        ],
      ),
    );
  }
}

class AgeRatingUI extends StatelessWidget {
  final AgeRating ageRating;

  const AgeRatingUI({Key? key, required this.ageRating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          ageRating.synopsis ?? 'No Description available',
          textAlign: TextAlign.center,
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      elevation: 4.0,
      child: Card(
        elevation: 3,
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${ageRating.category}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text('${ageRating.rating}'),
            ],
          ),
        ),
      ),
    );
  }
}
