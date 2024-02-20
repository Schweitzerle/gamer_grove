import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../singleton/sinlgleton.dart';

class CircularRatingWidget extends StatelessWidget{
  final double? ratingValue;

  const CircularRatingWidget({super.key, required this.ratingValue,});

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return  CircularPercentIndicator(
      radius: mediaQueryWidth * 0.07,
      lineWidth: 8.0,
      animation: true,
      animationDuration: 1000,
      percent: ratingValue != null
          ? Singleton.parseDouble(ratingValue) / 100
          : 0,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${ratingValue != null ? ratingValue!.toStringAsFixed(0) : 0}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.transparent,
      progressColor: Singleton.getCircleColor(
        Singleton.parseDouble(ratingValue),
      ),
    );
  }

}