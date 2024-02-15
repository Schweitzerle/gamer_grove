import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/genre.dart';
import 'package:gamer_grove/model/igdb_models/player_perspectiverequest_path.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../igdb_models/keyword.dart';
import '../views/gameGridPaginationView.dart';

class AllPlayerPerspectiveGridScreen extends StatelessWidget {
  static Route route(List<PlayerPerspective> playerPerspective, BuildContext context, String appBarText, Color color, Color textColor) {
    return MaterialPageRoute(
      builder: (context) => AllPlayerPerspectiveGridScreen(
        playerPerspective: playerPerspective, appBarText: appBarText, color: color, textColor: textColor,
      ),
    );
  }

  final List<PlayerPerspective> playerPerspective;
  final String appBarText;
  final Color color;
  final Color textColor;

  AllPlayerPerspectiveGridScreen({required this.appBarText, required this.playerPerspective, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    playerPerspective.sort((a, b) => a.name!.compareTo(b.name!));
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child:
          Wrap(
            children: playerPerspective.map((text) {
              return PlayerPerspectiveWidget(text: text, color: color, textColor: textColor);
            }).toList(),
          ),

      ),
    );
  }
}

class PlayerPerspectiveList extends StatelessWidget {
  final List<PlayerPerspective> playerPerspective;
  final Color color;
  final String headline;

  PlayerPerspectiveList(
      {required this.playerPerspective, required this.color, required this.headline});

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
                if (playerPerspective.length > 5)
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(AllPlayerPerspectiveGridScreen.route(
                            playerPerspective, context, headline, color, adjustedIconColor));
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
              children: playerPerspective.take(5).map((text) {
                return PlayerPerspectiveWidget(text: text, color: color, textColor: adjustedIconColor);
              }).toList(),
            ),
          ]),
        ),
      ),
    );
  }
}


class PlayerPerspectiveWidget extends StatelessWidget {
  final PlayerPerspective text;
  final Color color;
  final Color textColor;

  const PlayerPerspectiveWidget({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    print(text.name!);
    return GestureDetector(
      onTap: () {
        final body = 'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title;s follows desc; w follows != null  & player_perspectives = [${text.id}]; l 20;';
        Navigator.of(context).push(AllGamesGridPaginationScreen.route('Player Perspective: ${text.name}', body));
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
