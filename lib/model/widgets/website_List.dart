import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../igdb_models/website.dart'; // Annahme: Die Website-Klasse ist in website.dart definiert

class WebsiteList extends StatelessWidget {
  final List<Website> websites;

  const WebsiteList({Key? key, required this.websites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: websites.map((website) {
          return GestureDetector(
            onTap: () {
              _launchURL(website.url);
            },
            child: Container(
              margin: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildWebsiteIcon(website),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  //TODO: custom icon color
  Widget _buildWebsiteIcon(Website website) {
    IconData iconData;
    switch (website.category) {
      case CategoryEnum.official:
        iconData = Icons.public;
        break;
      case CategoryEnum.wikia:
        iconData = FontAwesomeIcons.wikipediaW;
        break;
      case CategoryEnum.wikipedia:
        iconData = FontAwesomeIcons.wikipediaW;
        break;
      case CategoryEnum.facebook:
        iconData = FontAwesomeIcons.facebook;
        break;
      case CategoryEnum.twitter:
        iconData = FontAwesomeIcons.twitter;
        break;
      case CategoryEnum.twitch:
        iconData = FontAwesomeIcons.twitch;
        break;
      case CategoryEnum.instagram:
        iconData = FontAwesomeIcons.instagram;
        break;
      case CategoryEnum.youtube:
        iconData = FontAwesomeIcons.youtube;
        break;
      case CategoryEnum.iphone:
        iconData = FontAwesomeIcons.apple;
        break;
      case CategoryEnum.ipad:
        iconData = FontAwesomeIcons.apple;
        break;
      case CategoryEnum.android:
        iconData = FontAwesomeIcons.android;
        break;
      case CategoryEnum.steam:
        iconData = FontAwesomeIcons.steam;
        break;
      case CategoryEnum.reddit:
        iconData = FontAwesomeIcons.reddit;
        break;
      case CategoryEnum.itch:
        iconData = FontAwesomeIcons.itchIo;
        break;
      case CategoryEnum.epicgames:
        iconData = FontAwesomeIcons.earlybirds;
        break;
      case CategoryEnum.gog:
        iconData = FontAwesomeIcons.galacticRepublic;
        break;
      case CategoryEnum.discord:
        iconData = FontAwesomeIcons.discord;
        break;
      default:
        iconData = Icons.link;
    }

    return Icon(iconData);
  }

  Future<void> _launchURL(String? urlString) async {
    final Uri url = Uri.parse(urlString!);
    if (!await launchUrl(url,
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}