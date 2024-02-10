import 'package:flutter/cupertino.dart';

import 'circular_rating_widget.dart';

class RatingWigdet extends StatelessWidget {
  final double rating;
  final String description;

  const RatingWigdet(
      {super.key, required this.rating, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: CircularRatingWidget(ratingValue: rating), flex: 1,),
        Expanded(child: Text(description), flex: 4,),
      ],
    );
  }
}
