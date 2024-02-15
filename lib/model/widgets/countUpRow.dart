import 'package:clay_containers/widgets/clay_container.dart';
import 'package:countup/countup.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class CountUpRow{
  static Widget buildCountupRow(IconData iconData, String? prefix, num? value,
      Color color, String? suffix, Color lightColor, BuildContext context, String description, Color darkColor) {

    final luminance = color.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor = luminance > targetLuminance ? color.darken(10) : color.lighten(10);

    return value != null ?
    JustTheTooltip(
      backgroundColor: darkColor,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          description,
          textAlign: TextAlign.center,
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      elevation: 4.0,
      child: Column(
        children: [
          FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClayContainer(
        borderRadius: 10,
          depth: 60,
          spread: 1,
          surfaceColor: lightColor,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(iconData, color: adjustedIconColor),
                      SizedBox(width: 8),
                      Countup(
                        begin: 0,
                        end: value.toDouble(),
                        prefix: prefix!,
                        suffix: suffix!.isNotEmpty ? suffix : '',
                        duration: Duration(seconds: 3),
                        separator: '.',
                        style: TextStyle(
                          color: adjustedIconColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
          ),
          SizedBox(height:5)
        ],
      ),
    ) : Container();
  }

}