// ==================================================
// MEDIA GALLERY
// ==================================================

// lib/presentation/pages/game_detail/widgets/media_gallery.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../domain/entities/game/game_video.dart';
import '../../imageGallery/image_gallery_page.dart';

class MediaGallery extends StatelessWidget {
  final List<String> screenshots;
  final List<GameVideo> videos;
  final List<String> artworks;

  const MediaGallery({
    super.key,
    required this.screenshots,
    required this.videos,
    required this.artworks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Media Gallery',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Videos Section
          if (videos.isNotEmpty) ...[
            Text(
              'Videos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return _buildVideoThumbnail(context, videos[index]);
                },
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          // Screenshots Section
          if (screenshots.isNotEmpty) ...[
            Text(
              'Screenshots',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: screenshots.length,
                itemBuilder: (context, index) {
                  return _buildScreenshotThumbnail(
                      context, screenshots[index], index);
                },
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],

          // Artworks Section
          if (artworks.isNotEmpty) ...[
            Text(
              'Artworks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: artworks.length,
                itemBuilder: (context, index) {
                  return _buildArtworkThumbnail(
                      context, artworks[index], index);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(BuildContext context, GameVideo video) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openVideoPlayer(context, video),
          child: Stack(
            children: [
              CachedImageWidget(
                imageUrl: video.thumbnailUrl,
                width: 300,
                height: 200,
                fit: BoxFit.cover,
              ),
              const Center(
                child: Icon(
                  Icons.play_circle_filled,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Text(
                    video.title ?? 'Game Video',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotThumbnail(
      BuildContext context, String imageUrl, int index) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openImageGallery(context, screenshots, index),
          child: CachedImageWidget(
            imageUrl: ImageUtils.getMediumImageUrl(imageUrl),
            width: 300,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildArtworkThumbnail(
      BuildContext context, String imageUrl, int index) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openImageGallery(context, artworks, index),
          child: CachedImageWidget(
            imageUrl: ImageUtils.getMediumImageUrl(imageUrl),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _openVideoPlayer(BuildContext context, GameVideo video) {
    // TODO: Implement video player or launch YouTube
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video.title ?? 'Game Video'),
        content: const Text('Video player will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openImageGallery(
      BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ImageGalleryPage(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}
