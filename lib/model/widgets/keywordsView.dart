import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../igdb_models/keyword.dart';
import '../views/gameGridPaginationView.dart';

class AllKeywordsGridScreen extends StatelessWidget {
  static Route route(List<Keyword> keywords, BuildContext context, String appBarText, Color color, Color textColor) {
    return MaterialPageRoute(
      builder: (context) => AllKeywordsGridScreen(
        keywords: keywords, appBarText: appBarText, color: color, textColor: textColor,
      ),
    );
  }

  final List<Keyword> keywords;
  final String appBarText;
  final Color color;
  final Color textColor;

  AllKeywordsGridScreen({required this.appBarText, required this.keywords, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    keywords.sort((a, b) => a.name!.compareTo(b.name!));
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child:
          Wrap(
            children: keywords.map((text) {
              return KeywordWidget(text: text, color: color.lighten(10));
            }).toList(),
          ),

      ),
    );
  }
}

class KeywordsList extends StatelessWidget {
  final List<Keyword> keywords;
  final Color color;
  final String headline;

  KeywordsList(
      {required this.keywords, required this.color, required this.headline});

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final luminance = color.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
    luminance > targetLuminance ? Colors.black : Colors.white;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClayContainer(
                  depth: 60,
                  spread: 2,
                  customBorderRadius: BorderRadius.circular(12),
                  color: color,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      headline,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: adjustedIconColor),
                    ),
                  ),
                ),
                if (keywords.length > 5)
                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            return color;
                          },
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(AllKeywordsGridScreen.route(
                            keywords, context, headline, color, adjustedIconColor));
                      },
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          'All',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: adjustedIconColor,
                          ),
                        ),
                      )),
              ],
            ),
            SizedBox(
              height: mediaQueryHeight * 0.01,
            ),
            Wrap(
              spacing: 5.0,
              runSpacing: 5.0,
              children: keywords.take(5).map((text) {
                return KeywordWidget(text: text, color: color.lighten(10));
              }).toList(),
            ),
          ]),
        ),
      ),
    );
  }
}


class KeywordWidget extends StatelessWidget {
  final Keyword text;
  final Color color;

  const KeywordWidget({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final luminance = color.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
    luminance > targetLuminance ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: () {
        final body = 'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title;s follows desc; w follows != null  & keywords = [${text.id}]; l 20;';
        Navigator.of(context).push(AllGamesGridPaginationScreen.route('Keywords: ${text.name}', body, false, null));
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: ClayContainer(
          depth: 60,
          spread: 2,
          color: color,
          customBorderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Text(
              text.name!,
              style: TextStyle(color: adjustedIconColor),
            ),
          ),
        ),
      ),
    );
  }
}
