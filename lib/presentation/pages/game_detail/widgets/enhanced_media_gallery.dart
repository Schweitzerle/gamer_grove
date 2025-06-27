// ==================================================
// ENHANCED MEDIA GALLERY - STAGGERED GRID VERSION
// ==================================================

// lib/presentation/pages/game_detail/widgets/enhanced_media_gallery.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../domain/entities/game.dart';
import '../../../../domain/entities/game_video.dart';

class EnhancedMediaGallery extends StatefulWidget {
  final Game game;

  const EnhancedMediaGallery({
    super.key,
    required this.game,
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
    if (widget.game.screenshots.isNotEmpty) tabCount++;
    if (widget.game.videos.isNotEmpty) tabCount++;
    if (widget.game.artworks.isNotEmpty) tabCount++;

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

    if (widget.game.screenshots.isNotEmpty) {
      tabs.add(Tab(text: 'Screenshots (${widget.game.screenshots.length})'));
      tabViews.add(_buildStaggeredImageGrid(widget.game.screenshots, 'screenshot'));
    }

    if (widget.game.videos.isNotEmpty) {
      tabs.add(Tab(text: 'Videos (${widget.game.videos.length})'));
      tabViews.add(_buildVideosView(widget.game.videos));
    }

    if (widget.game.artworks.isNotEmpty) {
      tabs.add(Tab(text: 'Artworks (${widget.game.artworks.length})'));
      tabViews.add(_buildStaggeredImageGrid(widget.game.artworks, 'artwork'));
    }

    if (tabs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: tabs,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
            ),
            SizedBox(
              height: 350, // Etwas höher für staggered grid
              child: TabBarView(
                controller: _tabController,
                children: tabViews,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Staggered Grid für Screenshots & Artworks
  Widget _buildStaggeredImageGrid(List<String> images, String type) {
    final displayImages = images.take(5).toList(); // Max 5 anzeigen
    final hasMore = images.length > 5;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: StaggeredGrid.count(
        axisDirection: AxisDirection.down,
        crossAxisCount: 4, // ✅ Erhöht von 4 auf 6 für bessere Platznutzung
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: [
          // Erstes Bild - groß (3x3)
          if (displayImages.isNotEmpty)
            StaggeredGridTile.count(
              crossAxisCellCount: 2, // ✅ Größer für bessere Proportionen
              mainAxisCellCount: 2,
              child: _buildImageTile(
                displayImages[0],
                images,
                0,
                type,
                isLarge: true,
              ),
            ),

          // Zweites Bild - hoch (3x2)
          if (displayImages.length > 1)
            StaggeredGridTile.count(
              crossAxisCellCount: 2, // ✅ Nutzt die rechte Hälfte
              mainAxisCellCount: 1,
              child: _buildImageTile(
                displayImages[1],
                images,
                1,
                type,
              ),
            ),

          // Drittes Bild - klein (2x1)
          if (displayImages.length > 2)
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: _buildImageTile(
                displayImages[2],
                images,
                2,
                type,
              ),
            ),

          // Viertes Bild - klein (1x1)
          if (displayImages.length > 3)
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: _buildImageTile(
                displayImages[3],
                images,
                3,
                type,
              ),
            ),

          // Fünftes Bild - mit "See All" Overlay wenn mehr vorhanden
          if (displayImages.length > 4)
            StaggeredGridTile.count(
              crossAxisCellCount: 4, // ✅ Nutzt verfügbaren Platz
              mainAxisCellCount: 2,
              child: _buildImageTile(
                displayImages[4],
                images,
                4,
                type,
                showSeeAll: hasMore,
                totalCount: images.length,
              ),
            ),
        ],
      ),
    );
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Bild
          Material(
            child: InkWell(
              onTap: () => showSeeAll
                  ? _showAllImages(allImages, type)
                  : _showFullScreenViewer(allImages, index, type),
              child: CachedImageWidget(
                imageUrl: ImageUtils.getMediumImageUrl(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // "See All" Overlay
          if (showSeeAll)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: isLarge ? 32 : 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isLarge ? 16 : 14,
                      ),
                    ),
                    Text(
                      '${totalCount} total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isLarge ? 12 : 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Fullscreen Image Viewer mit Swipe
  void _showFullScreenViewer(List<String> images, int initialIndex, String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
          title: type == 'screenshot' ? 'Screenshots' : 'Artworks',
        ),
      ),
    );
  }

  // ✅ Alle Bilder Grid View
  void _showAllImages(List<String> images, String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AllImagesGrid(
          images: images,
          title: type == 'screenshot' ? 'All Screenshots' : 'All Artworks',
          type: type,
        ),
      ),
    );
  }

  // ✅ Videos View (erstmal simplified)
  Widget _buildVideosView(List<GameVideo> videos) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 48,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    video.title ?? 'Video ${index + 1}',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==================================================
// FULLSCREEN IMAGE VIEWER
// ==================================================

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String title;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.title,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          // Bild Counter
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: CachedImageWidget(
                imageUrl: ImageUtils.getLargeImageUrl(widget.images[index]),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================================================
// ALL IMAGES GRID VIEW
// ==================================================

class AllImagesGrid extends StatelessWidget {
  final List<String> images;
  final String title;
  final String type;

  const AllImagesGrid({
    super.key,
    required this.images,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 16 / 9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      images: images,
                      initialIndex: index,
                      title: title,
                    ),
                  ),
                ),
                child: CachedImageWidget(
                  imageUrl: ImageUtils.getMediumImageUrl(images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}