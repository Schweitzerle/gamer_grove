// ==================================================
// ENHANCED MEDIA GALLERY - FIXED & CLEAN VERSION
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../domain/entities/event/event.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../../domain/entities/game/game_video.dart';
import '../../allVideosGrid/all_videos_grid.dart';
import '../../all_images_grid/all_images_grid.dart';
import '../../full_screen_image_viewer/full_screen_image_viewer.dart';
import '../../videoPlayer/video_player_screen.dart';

class EnhancedMediaGallery extends StatefulWidget {
  final Game? game;
  final Event? event;

  const EnhancedMediaGallery({
    super.key,
    this.game,
    this.event,
  });

  @override
  State<EnhancedMediaGallery> createState() => _EnhancedMediaGalleryState();
}

class _EnhancedMediaGalleryState extends State<EnhancedMediaGallery>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
  }

  void _initializeTabs() {
    int tabCount = 0;
    if (widget.game != null) {
      if (widget.game!.screenshots.isNotEmpty) tabCount++;
      if (widget.game!.videos.isNotEmpty) tabCount++;
      if (widget.game!.artworks.isNotEmpty) tabCount++;
    }

    if (widget.event != null) {
      if (widget.event!.videos.isNotEmpty) tabCount++;
    }

    if (tabCount > 0) {
      _tabController = TabController(length: tabCount, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = [];
    final List<Widget> tabViews = [];

    if (widget.game != null) {
      if (widget.game!.screenshots.isNotEmpty) {
        tabs.add(Tab(text: 'Screenshots (${widget.game!.screenshots.length})'));
        final screenshotUrls = widget.game!.screenshots
            .map((screenshot) => screenshot.hdUrl)
            .toList();
        tabViews.add(_buildStaggeredImageGrid(screenshotUrls, 'screenshot'));
      }

      if (widget.game!.artworks.isNotEmpty) {
        tabs.add(Tab(text: 'Artworks (${widget.game!.artworks.length})'));
        final artworkUrls =
            widget.game!.artworks.map((artwork) => artwork.hdUrl).toList();
        tabViews.add(_buildStaggeredImageGrid(artworkUrls, 'artwork'));
      }

      if (widget.game!.videos.isNotEmpty) {
        tabs.add(Tab(text: 'Videos (${widget.game!.videos.length})'));
        tabViews.add(_buildVideosView(widget.game!.videos));
      }
    }

    if (widget.event != null) {
      if (widget.event!.videos.isNotEmpty) {
        tabs.add(Tab(text: 'Videos (${widget.event!.videos.length})'));
        tabViews.add(_buildVideosView(widget.event!.videos));
      }
    }

    if (tabs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: tabs,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              isScrollable: true,
            ),
            SizedBox(
              height: 320, // Optimierte Höhe
              child: tabs.length > 1
                  ? TabBarView(
                      controller: _tabController,
                      children: tabViews,
                    )
                  : tabViews.first,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Staggered Grid für Images
  Widget _buildStaggeredImageGrid(List<String> images, String type) {
    if (images.isEmpty) return const Center(child: Text('No images available'));

    final displayImages = images.take(5).toList();
    final hasMore = images.length > 5;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Center(
        child: StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          axisDirection: AxisDirection.down,
          children: _buildStaggeredTiles(displayImages, images, type, hasMore),
        ),
      ),
    );
  }

  // ✅ Staggered Tiles erstellen
  List<StaggeredGridTile> _buildStaggeredTiles(List<String> displayImages,
      List<String> allImages, String type, bool hasMore) {
    final tiles = <StaggeredGridTile>[];

    for (int i = 0; i < displayImages.length; i++) {
      final isLastTile = i == displayImages.length - 1;
      final showSeeAll = isLastTile && hasMore;

      late int crossAxisCells;
      late int mainAxisCells;

      switch (i) {
        case 0: // Hauptbild links
          crossAxisCells = 2;
          mainAxisCells = 2;
          break;
        case 1: // Oben rechts
          crossAxisCells = 2;
          mainAxisCells = 1;
          break;
        case 2: // Unten rechts 1 (quadratisch)
          crossAxisCells = 1;
          mainAxisCells = 1;
          break;
        case 3: // Unten rechts 2 (quadratisch)
          crossAxisCells = 1;
          mainAxisCells = 1;
          break;
        case 4: // See All (falls vorhanden)
          crossAxisCells = 4;
          mainAxisCells = 2;
          break;
        default:
          crossAxisCells = 1;
          mainAxisCells = 1;
      }

      tiles.add(
        StaggeredGridTile.count(
          crossAxisCellCount: crossAxisCells,
          mainAxisCellCount: mainAxisCells,
          child: _buildImageTile(
            displayImages[i],
            allImages,
            i,
            type,
            isLarge: i == 0,
            showSeeAll: showSeeAll,
            totalCount: allImages.length,
          ),
        ),
      );
    }

    return tiles;
  }

  // ✅ Einzelne Image Tile
  Widget _buildImageTile(
    String imageUrl,
    List<String> allImages,
    int index,
    String type, {
    bool isLarge = false,
    bool showSeeAll = false,
    int? totalCount,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (showSeeAll) {
              _showAllImages(allImages, type);
            } else {
              _showFullScreenViewer(allImages, index, type);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hintergrundbild
              Hero(
                tag: 'image_${type}_$index',
                child: CachedImageWidget(
                  imageUrl: ImageUtils.getMediumImageUrl(imageUrl),
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Icon(
                      Icons.broken_image,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),

              // See All Overlay
              if (showSeeAll)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: isLarge ? 32 : 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'See All',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isLarge ? 16 : 14,
                          ),
                        ),
                        if (totalCount != null)
                          Text(
                            '+${totalCount - index} more',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isLarge ? 12 : 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Videos View
  Widget _buildVideosView(List<GameVideo> videos) {
    if (videos.isEmpty) return const Center(child: Text('No videos available'));

    final displayVideos = videos.take(5).toList();
    final hasMore = videos.length > 5;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: displayVideos.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // See All Video Tile
        if (hasMore && index == displayVideos.length) {
          return _buildSeeAllVideoTile(videos);
        }

        // Normal Video Tile
        final video = displayVideos[index];
        return _buildVideoTile(video, index);
      },
    );
  }

  Widget _buildVideoTile(GameVideo video, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openVideoPlayer(video, index),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // YouTube Thumbnail
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // YouTube Thumbnail
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: CachedImageWidget(
                            imageUrl: video.thumbnailUrl,
                            // ✅ Verwendet den getter
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: Colors.red.withOpacity(0.1),
                              child: const Icon(
                                Icons.smart_display,
                                color: Colors.red,
                                size: 32,
                              ),
                            ),
                          ),
                        ),

                        // YouTube Play Button
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9), // YouTube rot
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // YouTube Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'YT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Video Info
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    video.title ?? 'YouTube Video ${index + 1}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ See All Videos Tile
  Widget _buildSeeAllVideoTile(List<GameVideo> allVideos) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showAllVideos(allVideos),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'See All Videos',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${allVideos.length} total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Navigation Methoden
  void _showFullScreenViewer(
      List<String> images, int initialIndex, String type) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, _) => FadeTransition(
          opacity: animation,
          child: FullScreenImageViewer(
            images: images,
            initialIndex: initialIndex,
            title: type == 'screenshot' ? 'Screenshots' : 'Artworks',
            gameName: widget.game?.name ?? '',
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showAllImages(List<String> images, String type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AllImagesGrid(
          images: images,
          title: type == 'screenshot' ? 'All Screenshots' : 'All Artworks',
          type: type,
          gameName: widget.game?.name ?? '',
        ),
      ),
    );
  }

  void _openVideoPlayer(GameVideo video, int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => VideoPlayerScreen(
          video: video,
          videoIndex: index,
        ),
      ),
    );
  }

  void _showAllVideos(List<GameVideo> videos) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AllVideosGrid(
          videos: videos,
          title: 'All Videos',
          gameName: widget.game?.name ?? '',
        ),
      ),
    );
  }
}
