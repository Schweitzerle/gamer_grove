import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/features/home/home_screen.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:gamer_grove/model/igdb_models/game_video.dart';

class VideoPlayerItem extends StatefulWidget {
  final GameVideo gameVideo;
  final Color color;  

  VideoPlayerItem({required this.gameVideo, required this.color});

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final luminance = widget.color.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor = luminance > targetLuminance ? Colors.black : Colors.white;

    return AspectRatio(
      aspectRatio: 16/11,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VideoDetailScreen(gameVideo: widget.gameVideo)),
          );
        },
        child: GlassContainer(
          blur: 12,
          shadowStrength: 2,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(14),
          color: widget.color.withOpacity(.3),
          shadowColor: widget.color.lighten(20),
          child: Column(
            children: [
              Expanded(
                flex: 12,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 16/9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 16/9,
                                child: CachedNetworkImage(
                                imageUrl: 'https://img.youtube.com/vi/${widget.gameVideo.videoId}/hqdefault.jpg',
                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                  fit: BoxFit.cover,
                                                            ),
                              ),
                              Center(
                                child: GlassContainer(
                                  blur: 12,
                                  shadowStrength: 2,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(14),
                                  shadowColor: widget.color.lighten(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: widget.color.lighten(10),
                                      size: 48.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ),
                    ),
                  ),
                ),
              ),
              ),
              Expanded(
                  flex: 2, child: Center(child: Text('${widget.gameVideo.name}', style: TextStyle(color: adjustedIconColor),)))
            ],
          ),
        ),
      ),
    );
  }
}

class VideoDetailScreen extends StatefulWidget {
  final GameVideo gameVideo;

  VideoDetailScreen({required this.gameVideo});

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late YoutubePlayerController _controller;
  bool _fullScreen = false;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.gameVideo.videoId!,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    )..addListener(listener);
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      setState(() {});
    }
    setState(() {
      _fullScreen = _controller.value.isFullScreen;
    });
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _fullScreen ? null : AppBar(
        title: Text(_controller.metadata.title),
      ),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          bufferIndicator: const Center(
            child: LoadingIndicator(
              indicatorType: Indicator.pacman,
            ),
          ),
          controller: _controller,
          showVideoProgressIndicator: true,
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _controller.metadata.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
          onReady: () {
            _isPlayerReady = true;
          },
        ),
        builder: (context, player) {
          return Center(
            child: player,
          );
        }
      ),
    );
  }
}
