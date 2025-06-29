// lib/presentation/pages/game_detail/widgets/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/game/game_video.dart';

class VideoPlayerScreen extends StatefulWidget {
  final GameVideo video;
  final int videoIndex;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.videoIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _youtubeController;
  bool _isPlayerReady = false;
  bool _showPlayer = true;

  @override
  void initState() {
    super.initState();
    _initializeYouTubePlayer();
  }

  void _initializeYouTubePlayer() {
    try {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.video.videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      );
    } catch (e) {
      setState(() {
        _showPlayer = false;
      });
    }
  }

  Future<void> _openInYouTubeOrBrowser() async {
    try {
      // Erst versuchen YouTube App zu öffnen
      final youtubeAppUrl = 'youtube://watch?v=${widget.video.videoId}';

      if (await canLaunchUrl(Uri.parse(youtubeAppUrl))) {
        await launchUrl(
          Uri.parse(youtubeAppUrl),
          mode: LaunchMode.externalApplication,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening in YouTube app...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Fallback: Browser öffnen
        await launchUrl(
          Uri.parse(widget.video.youtubeUrl),
          mode: LaunchMode.externalApplication,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening in browser...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareVideo() {
    Clipboard.setData(ClipboardData(text: widget.video.youtubeUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Text('YouTube URL copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    try {
      _youtubeController.dispose();
    } catch (e) {
      // Ignore dispose errors
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        // Fullscreen Layout für Landscape
        if (orientation == Orientation.landscape) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox.expand(
              child: _buildVideoPlayer(),
            ),
          );
        }

        // Portrait Layout (Original)
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.8),
            foregroundColor: Colors.white,
            title: Text(
              widget.video.title ?? 'Video ${widget.videoIndex + 1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_new),
                tooltip: 'Open in YouTube',
                onPressed: _openInYouTubeOrBrowser,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Share video',
                onPressed: _shareVideo,
              ),
            ],
          ),
          body: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Video Title Section - über dem Player
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // YouTube Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.smart_display,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'YouTube',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isPlayerReady) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ready',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Video Title
                      Text(
                        widget.video.title ?? 'Video ${widget.videoIndex + 1}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // YouTube Player - zentriert und größer
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildVideoPlayer(),
                    ),
                  ),
                ),

                // Bottom Spacing
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer() {
    if (!_showPlayer) {
      return _buildFallbackPlayer();
    }

    try {
      return YoutubePlayer(
        controller: _youtubeController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          if (mounted) {
            setState(() {
              _isPlayerReady = true;
            });
          }
        },
        onEnded: (metaData) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video finished')),
            );
          }
        },
      );
    } catch (e) {
      return _buildFallbackPlayer();
    }
  }

  Widget _buildFallbackPlayer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail Background
          CachedImageWidget(
            imageUrl: widget.video.thumbnailUrl,
            fit: BoxFit.cover,
            errorWidget: Container(
              color: Colors.grey[900],
              child: const Icon(
                Icons.videocam_off,
                color: Colors.grey,
                size: 64,
              ),
            ),
          ),

          // Overlay
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Play Button
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _openInYouTubeOrBrowser,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tap to open in YouTube',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}