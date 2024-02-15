import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/game_video.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/video_player_view.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';

class VideosGridView extends StatelessWidget {
  final List<GameVideo> videos;
  final Color color;

  VideosGridView({
    required this.videos, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 16/9,
          crossAxisCount: 1,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final video = videos[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: VideoPlayerItem(gameVideo: video, color: color,)),
          );
        },
        childCount: videos.length,
      ),
    );
  }
}

class AllVideosGridScreen extends StatelessWidget {
  static Route route(List<GameVideo> videos, BuildContext context, String appBarText, Color color) {
    return MaterialPageRoute(
      builder: (context) => AllVideosGridScreen(
        videos: videos, appBarText: appBarText, color: color,
      ),
    );
  }

  final List<GameVideo> videos;
  final String appBarText;
  final Color color;
  AllVideosGridScreen({required this.videos, required this.appBarText, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
      ),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          VideosGridView(videos: videos, color: color,),
        ],
      ),
    );
  }
}
