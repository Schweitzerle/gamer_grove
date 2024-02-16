import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/genre.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../igdb_models/keyword.dart';
import '../views/gameGridPaginationView.dart';

class AllGenresGridScreen extends StatelessWidget {
  static Route route(List<Genre> genres, BuildContext context, String appBarText, Color color, Color textColor) {
    return MaterialPageRoute(
      builder: (context) => AllGenresGridScreen(
        genres: genres, appBarText: appBarText, color: color, textColor: textColor,
      ),
    );
  }

  final List<Genre> genres;
  final String appBarText;
  final Color color;
  final Color textColor;

  AllGenresGridScreen({required this.appBarText, required this.genres, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    genres.sort((a, b) => a.name!.compareTo(b.name!));
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child:
          Wrap(
            children: genres.map((text) {
              return GenreWidget(text: text, color: color, textColor: textColor);
            }).toList(),
          ),

      ),
    );
  }
}

class GenresList extends StatelessWidget {
  final List<Genre> genres;
  final Color color;
  final String headline;

  GenresList(
      {required this.genres, required this.color, required this.headline});

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final luminance = color.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
    luminance > targetLuminance ? Colors.black : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(.3),
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
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      headline,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Theme.of(context).cardTheme.surfaceTintColor),
                    ),
                  ),
                ),
                if (genres.length > 5)
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(AllGenresGridScreen.route(
                            genres, context, headline, color, adjustedIconColor));
                      },
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          'All',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: color,
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
              children: genres.take(5).map((text) {
                return GenreWidget(text: text, color: color, textColor: adjustedIconColor);
              }).toList(),
            ),
          ]),
        ),
      ),
    );
  }
}


class GenreWidget extends StatelessWidget {
  final Genre text;
  final Color color;
  final Color textColor;

  const GenreWidget({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final body = 'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title;s follows desc; w follows != null  & genres = [${text.id}]; l 20;';
        Navigator.of(context).push(AllGamesGridPaginationScreen.route('Genre: ${text.name}', body));
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClayContainer(
          depth: 60,
          spread: 2,
          color: color,
          customBorderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Text(
              text.name!,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
