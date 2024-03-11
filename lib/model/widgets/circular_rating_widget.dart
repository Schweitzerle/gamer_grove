import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../singleton/sinlgleton.dart';

class CircularRatingWidget extends StatelessWidget{
  final double? ratingValue;
  final double radiusMultiplicator;
  final double fontSize;
  final double lineWidth;

  const CircularRatingWidget({super.key, required this.ratingValue, required this.radiusMultiplicator, required this.fontSize, required this.lineWidth,});

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return  Container(

      child: CircularPercentIndicator(
        radius: mediaQueryWidth * radiusMultiplicator,
        lineWidth: lineWidth,
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
                fontWeight: FontWeight.bold,
                fontSize: fontSize
              ),
            ),
          ],
        ),
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: Colors.transparent,
        progressColor: Singleton.getCircleColor(
          Singleton.parseDouble(ratingValue),
        ),
      ),
    );
  }

}