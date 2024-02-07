import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoRow {
  static Widget buildInfoRow(IconData iconData, String? text, Color color,
      Color iconColor, bool isLink) {
    return text != null
        ? Column(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10), // Add rounded corn
                ),
                child: Row(
                  children: [
                    Icon(iconData, color: iconColor),
                    SizedBox(width: 8),
                    isLink
                        ? GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(text);
                              if (!await launchUrl(url,
                                  mode: LaunchMode.externalApplication)) {
                                throw Exception('Could not launch $url');
                              }
                            },
                            child: Text(
                              'IGDB Website',
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : Text(
                            text,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 16,
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              )
            ],
          )
        : Container();
  }
}
