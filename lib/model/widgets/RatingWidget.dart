import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'circular_rating_widget.dart';

class RatingWigdet extends StatelessWidget {
  final double rating;
  final String description;
  final Color color;

  const RatingWigdet(
      {super.key, required this.rating, required this.description, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14), color: color
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: CircularRatingWidget(ratingValue: rating, radiusMultiplicator: .07, fontSize: 18, lineWidth: 6,), flex: 1,),
              Expanded(child: Text(description, style: TextStyle(color: Colors.white),), flex: 4,),
            ],
          ),
        ),
      ),
    );
  }
}
