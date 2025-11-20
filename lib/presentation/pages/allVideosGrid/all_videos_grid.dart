// ==================================================
// ALL VIDEOS GRID
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer_grove/core/widgets/cached_image_widget.dart';
import 'package:gamer_grove/domain/entities/game/game_video.dart';
import 'package:gamer_grove/presentation/pages/videoPlayer/video_player_screen.dart';

class AllVideosGrid extends StatelessWidget {

  const AllVideosGrid({
    required this.videos, required this.title, required this.gameName, super.key,
  });
  final List<GameVideo> videos;
  final String title;
  final String gameName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    gameName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${videos.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 16 / 12,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => VideoPlayerScreen(
                          video: video,
                          videoIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Thumbnail
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedImageWidget(
                              imageUrl: video.thumbnailUrl,
                              placeholder: ColoredBox(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                            // Play button
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 28,
                                ),
                              ),
                            ),
                            // Video title overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  video.title ?? 'Video ${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
