import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/game_video.dart';
import 'package:gamer_grove/model/views/eventGridView.dart';
import 'package:gamer_grove/model/views/videosGridView.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/video_player_view.dart';
import 'package:get/get_utils/get_utils.dart';
import '../igdb_models/game.dart';

class VideoListView extends StatefulWidget {
  final String headline;
  final List<GameVideo>? videos;

  VideoListView({
    required this.headline,
    required this.videos
  });

  @override
  State<StatefulWidget> createState() => VideoListViewState();
}

class VideoListViewState extends State<VideoListView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    return widget.videos != null && widget.videos!.isNotEmpty
        ? AspectRatio(aspectRatio: 16/9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
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
                        widget.headline,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .cardTheme
                                .surfaceTintColor),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(AllVideosGridScreen.route(widget.videos!, context, widget.headline));                    },
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'All',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .cardTheme
                                .surfaceTintColor),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: mediaQueryHeight * 0.01,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.videos!.length,
                itemBuilder: (context, index) {
                  if (index >= widget.videos!.length) {
                    return null; // or a placeholder widget
                  }
                  GameVideo video = widget.videos![index];
                  return AspectRatio(aspectRatio: 16/9,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: VideoPlayerItem(
                        gameVideo: video
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ))
        : Container();
  }
}
