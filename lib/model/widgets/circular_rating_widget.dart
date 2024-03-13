import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../singleton/sinlgleton.dart';

class CircularRatingWidget extends StatelessWidget{
  final double ratingValue;
  final double radiusMultiplicator;
  final double fontSize;
  final double lineWidth;

  const CircularRatingWidget({super.key, required this.ratingValue, required this.radiusMultiplicator, required this.fontSize, required this.lineWidth,});

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return  CircularPercentIndicator(
      radius: mediaQueryWidth * radiusMultiplicator,
      lineWidth: lineWidth,
      animation: true,
      animationDuration: 1000,
      percent:  Singleton.parseDouble(ratingValue) / 100,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ratingValue.toStringAsFixed(0),
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
      progressColor: getCircleColor(
        Singleton.parseDouble(ratingValue / 10),
      ),
    );
  }

  static Color getCircleColor(double rating) {
    if (rating < 2.5) {
      return Color(0xFF212121);
    } else if (rating >= 2.5 && rating <= 5.0) {
      return Color(0xFF6E3A06);
    } else if (rating >= 5.0 && rating <= 7.0) {
      return Color(0xFF87868c);
    } else if (rating >= 7.0 && rating <= 8.5) {
      return Color(0xFFA48111);
    } else {
      return Color(0xFF6B0000);
    }
  }


}