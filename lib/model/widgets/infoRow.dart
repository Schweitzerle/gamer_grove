import 'package:clay_containers/clay_containers.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoRow {
  static Widget buildInfoRow(IconData iconData, String? text, Color color,
      Color iconColor, bool isLink, BuildContext context) {

      final luminance = color.computeLuminance();
      final targetLuminance = 0.5;

      final adjustedIconColor = luminance > targetLuminance ? iconColor.darken(10) : iconColor.lighten(10);

      return Column(
        children: [
          FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: ClayContainer(
                borderRadius: 10,
                spread: 1,
                depth: 60,
                surfaceColor: color,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(iconData, color: adjustedIconColor), // Verwenden der angepassten Icon-Farbe
                      SizedBox(width: 8),
                      isLink
                          ? GestureDetector(
                        onTap: () async {
                          final Uri url = Uri.parse(text!);
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            throw Exception('Could not launch $url');
                          }
                        },
                        child: Text(
                          'IGDB Website',
                          style: TextStyle(
                            color: adjustedIconColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                          : Text(
                        text!,
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
          SizedBox(height: 5),
        ],
      );
    }
  }

