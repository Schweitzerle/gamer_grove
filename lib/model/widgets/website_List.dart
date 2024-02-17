import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../igdb_models/website.dart'; // Annahme: Die Website-Klasse ist in website.dart definiert

class WebsiteList extends StatelessWidget {
  final List<Website> websites;
  final Color lightColor;

  const WebsiteList({Key? key, required this.websites, required this.lightColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final luminance = lightColor.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
    luminance > targetLuminance ? Colors.black : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: websites.map((website) {
              return GestureDetector(
                onTap: () {
                  _launchURL(website.url);
                },
                child: Container(
                  margin: EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildWebsiteIcon(website),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


  //TODO: custom icon color
  Widget _buildWebsiteIcon(Website website) {
    IconData iconData;
    Color iconColor;
    switch (website.category) {
      case CategoryEnum.official:
        iconData = Icons.public;
        iconColor = Color(0xFF07355A);
        break;
      case CategoryEnum.wikia:
        iconData = FontAwesomeIcons.wikipediaW;
        iconColor = Color(0xFF939598);
        break;
      case CategoryEnum.wikipedia:
        iconData = FontAwesomeIcons.wikipediaW;
        iconColor = Color(0xFFc7c8ca);
        break;
      case CategoryEnum.facebook:
        iconData = FontAwesomeIcons.facebook;
        iconColor = Color(0xFF1877f2);
        break;
      case CategoryEnum.twitter:
        iconData = FontAwesomeIcons.twitter;
        iconColor = Color(0xFF1da1f2);
        break;
      case CategoryEnum.twitch:
        iconData = FontAwesomeIcons.twitch;
        iconColor = Color(0xFF9146ff);
        break;
      case CategoryEnum.instagram:
        iconData = FontAwesomeIcons.instagram;
        iconColor = Color(0xFFc13584);
        break;
      case CategoryEnum.youtube:
        iconData = FontAwesomeIcons.youtube;
        iconColor = Color(0xFFff0000);
        break;
      case CategoryEnum.iphone:
        iconData = FontAwesomeIcons.apple;
        iconColor = Color(0xFF000000);
        break;
      case CategoryEnum.ipad:
        iconData = FontAwesomeIcons.apple;
        iconColor = Color(0xFF000000);
        break;
      case CategoryEnum.android:
        iconData = FontAwesomeIcons.android;
        iconColor = Color(0xFFa4c639);
        break;
      case CategoryEnum.steam:
        iconData = FontAwesomeIcons.steam;
        iconColor = Color(0xFF00adee);
        break;
      case CategoryEnum.reddit:
        iconData = FontAwesomeIcons.reddit;
        iconColor = Color(0xFFff4500);
        break;
      case CategoryEnum.itch:
        iconData = FontAwesomeIcons.itchIo;
        iconColor = Color(0xFFfa5c5c);
        break;
      case CategoryEnum.epicgames:
        iconData = FontAwesomeIcons.earlybirds;
        iconColor = Color(0xFF242424);
        break;
      case CategoryEnum.gog:
        iconData = FontAwesomeIcons.galacticRepublic;
        iconColor = Color(0xFF7cb4dc);
        break;
      case CategoryEnum.discord:
        iconData = FontAwesomeIcons.discord;
        iconColor = Color(0xFF5865f2);
        break;
      default:
        iconData = Icons.link;
        iconColor = Color(0xFF07355A);
    }

    return Icon(iconData, color: iconColor,);
  }

  Future<void> _launchURL(String? urlString) async {
    final Uri url = Uri.parse(urlString!);
    if (!await launchUrl(url,
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
