// ==================================================
// FULLSCREEN IMAGE VIEWER
// ==================================================

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/core/widgets/cached_image_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenImageViewer extends StatefulWidget {

  const FullScreenImageViewer({
    required this.images, required this.initialIndex, required this.title, required this.gameName, super.key,
  });
  final List<String> images;
  final int initialIndex;
  final String title;
  final String gameName;

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _isUIVisible = true;

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

  void _toggleUI() {
    setState(() {
      _isUIVisible = !_isUIVisible;
    });
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),),
              SizedBox(width: 16),
              Text('Downloading image...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // ✅ Vereinfachte Permission-Logik
      if (Platform.isAndroid) {
        // Erst photos, dann storage als fallback
        var hasPermission = false;

        try {
          final photosPermission = await Permission.photos.request();
          hasPermission = photosPermission.isGranted;
        } catch (e) {
          // Fallback zu storage permission
          final storagePermission = await Permission.storage.request();
          hasPermission = storagePermission.isGranted;
        }

        if (!hasPermission) {
          _showErrorSnackBar('Permission needed to save images to gallery');
          return;
        }
      }

      // Image downloaden
      final dio = Dio();
      final imageResponse = await dio.get<List<int>>(
        ImageUtils.getLargeImageUrl(imageUrl),
        options: Options(responseType: ResponseType.bytes),
      );

      if (imageResponse.statusCode == 200 && imageResponse.data != null) {
        // Temporäre Datei erstellen
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'gamer_grove_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(imageResponse.data!);

        // In Galerie speichern
        await Gal.putImage(tempFile.path, album: 'Gamer Grove');

        // Temp file löschen
        await tempFile.delete();

        _showSuccessSnackBar('Image saved to gallery');
      } else {
        _showErrorSnackBar('Failed to download image');
      }
    } catch (e) {
      _showErrorSnackBar('Download failed: $e');
    }
  }

// Helper Methoden hinzufügen:
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _isUIVisible
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              foregroundColor: Colors.white,
              title: Text(widget.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadImage(widget.images[_currentIndex]),
                ),
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
            )
          : null,
      body: GestureDetector(
        onTap: _toggleUI,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Hero(
                  tag: 'image_fullscreen_$index',
                  child: CachedImageWidget(
                    imageUrl: ImageUtils.getLargeImageUrl(widget.images[index]),
                    fit: BoxFit.contain,
                    placeholder: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _isUIVisible && widget.images.length > 1
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _currentIndex > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                  Text(
                    '${_currentIndex + 1} of ${widget.images.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white,),
                    onPressed: _currentIndex < widget.images.length - 1
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
