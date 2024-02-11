import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:gamer_grove/model/igdb_models/age_rating.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class AgeRatingListUI extends StatelessWidget {
  final List<AgeRating> ageRatings;
  final Color color; 

  const AgeRatingListUI({Key? key, required this.ageRatings, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:
          Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: ageRatings
                .map((ageRating) => AgeRatingUI(ageRating: ageRating, color: color,))
                .toList(),
          ),
    );
  }
}

class AgeRatingUI extends StatelessWidget {
  final AgeRating ageRating;
  final Color color;

  const AgeRatingUI({Key? key, required this.ageRating, required this.color}) : super(key: key);

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
        child: GestureDetector(
          onTap: () {
            //TODO: zu gridview
          },
          child: ClayContainer(
            depth: 60,
            spread: 2,
            color: color,
            customBorderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: Text(
                '${ageRating.category}: ${ageRating.rating}',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ));
  }
}
