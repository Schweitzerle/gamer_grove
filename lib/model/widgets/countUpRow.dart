import 'package:countup/countup.dart';
import 'package:flutter/cupertino.dart';

class CountUpRow{
  static Widget buildCountupRow(IconData iconData, String? prefix, num? value,
      Color color, String? suffix, Color lightColor) {
    return value != null ? Column(
      children: [
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: lightColor.withOpacity(.95),
            borderRadius: BorderRadius.circular(10), // Add rounded corn
          ),
          child: Row(
            children: [
              Icon(iconData, color: color),
              SizedBox(width: 8),
              Countup(
                begin: 0,
                end: value.toDouble(),
                prefix: prefix!,
                suffix: suffix!.isNotEmpty ? suffix : '',
                duration: Duration(seconds: 3),
                separator: '.',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height:5)
      ],
    ) : Container();
  }

}