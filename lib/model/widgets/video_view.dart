import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gamer_grove/features/home/home_screen.dart';
import 'package:gamer_grove/model/igdb_models/collection.dart';
import 'package:gamer_grove/model/igdb_models/franchise.dart';
import 'package:gamer_grove/model/igdb_models/game_video.dart';
import 'package:gamer_grove/model/views/videosGridView.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/video_player_view.dart';

import '../igdb_models/game.dart';
import '../views/gameGridView.dart';
class VideoStaggeredView extends StatelessWidget{
  final Game game;
  final Color colorPalette;
  final Color headerBorderColor;
  final Color adjustedTextColor;

  const VideoStaggeredView({super.key, required this.game, required this.colorPalette, required this.headerBorderColor, required this.adjustedTextColor});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 8,
          children: [
            if (game.videos != null)
              StaggeredGridTile.count(
                crossAxisCellCount: 3,
                mainAxisCellCount: 2,
                child: VideoItemPreview(
                  videos: game.videos!,
                  color: colorPalette,
                ),
              ),
            if (game.videos != null)
              StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 1,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        AllVideosGridScreen.route(
                            game.videos!,
                            context,
                            'Videos', colorPalette));
                  },
                  child: ClayContainer(
                    spread: 2,
                    depth: 60,
                    borderRadius: 14,
                    color: headerBorderColor,
                    parentColor: headerBorderColor.lighten(40),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: FittedBox(
                        child: Row(
                          children: [
                            Text(
                              'Videos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: adjustedTextColor,
                              ),
                            ),
                            Icon(Icons.navigate_next_rounded)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (game.videos != null)
              StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Container()),
          ]),
    );
  }
}

class VideoItemPreview extends StatelessWidget {
  final List<GameVideo> videos;
  final Color color;

  const VideoItemPreview({
    Key? key,
    required this.videos,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final containerBackgroundColor = color.darken(20);
    final headerBorderColor = color;
    final contentBackgroundColor = color.darken(10).withOpacity(.8);

    // Shuffle the list of videos
    final List<GameVideo> shuffledVideos = List.from(videos)..shuffle();
    // Select the first video from the shuffled list
    final GameVideo selectedVideo = shuffledVideos.first;

    return ClayContainer(
      spread: 2,
      depth: 60,
      borderRadius: 14,
      color: containerBackgroundColor,
      parentColor: headerBorderColor.lighten(40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: VideoPlayerItem(gameVideo: selectedVideo, color: containerBackgroundColor),
      ),
    );
  }
}

