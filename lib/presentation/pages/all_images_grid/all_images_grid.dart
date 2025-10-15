// ==================================================
// ALL IMAGES GRID
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../full_screen_image_viewer/full_screen_image_viewer.dart';

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
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 16 / 10,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, _) => FadeTransition(
                        opacity: animation,
                        child: FullScreenImageViewer(
                          images: images,
                          initialIndex: index,
                          title: title,
                        ),
                      ),
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                child: Hero(
                  tag: 'grid_image_$index',
                  child: CachedImageWidget(
                    imageUrl: ImageUtils.getMediumImageUrl(images[index]),
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
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
