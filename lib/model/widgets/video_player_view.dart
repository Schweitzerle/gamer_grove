import 'dart:developer';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/features/home/home_screen.dart';
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
  late YoutubePlayerController _controller;

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
      setState(() {});
    }
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

    final luminance = widget.color.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor = luminance > targetLuminance ? Colors.black : Colors.white;

    return AspectRatio(
      aspectRatio: 16/11,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: widget.color,
        ),
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
                    child: YoutubePlayer(
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
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 2, child: Center(child: Text('${widget.gameVideo.name}', style: TextStyle(color: adjustedIconColor),)))
          ],
        ),
      ),
    );
  }
}
