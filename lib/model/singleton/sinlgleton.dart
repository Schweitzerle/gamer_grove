import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Singleton extends StatelessWidget {
  const Singleton({Key? key}) : super(key: key);

  static Color firstTabColor = Color(0xff5ac45a);
  static Color secondTabColor = Color(0xff36a036);
  static Color thirdTabColor = Color(0xff2ca243);
  static Color fourthTabColor = Color(0xff0c5b0c);
  static Color fifthTabColor = Color(0xff044404);
  static Color mainColor = Color(0xff091309);
  static Color highlightColor = Color(0xffffffff);


  static double parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      // Handle other cases, such as string representation of a number
      return double.tryParse(value.toString()) ?? 0.0;
    }
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


  @override
  Widget build(BuildContext context) {
    return Container();
  }
}