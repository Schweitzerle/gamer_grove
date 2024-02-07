import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../igdb_models/game.dart';

class PhotoView extends StatelessWidget {
  final Game game;
  final int index;
  final bool isArtwork;

  const PhotoView({
    Key? key,
    required this.game,
    required this.index, required this.isArtwork,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArtwork ? "Artwork Bild" : "Screenshot Bild"),
      ),
      body:  PhotoViewGallery.builder(
        itemCount: isArtwork ? game.artworks?.length : game.screenshots?.length,
        builder: (context, index) => PhotoViewGalleryPageOptions.customChild(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: isArtwork ? game.artworks![index].url! : game.screenshots![index].url!,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.inversePrimary, //TODO: Shimmer
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          minScale: PhotoViewComputedScale.covered,
          heroAttributes: PhotoViewHeroAttributes(tag: isArtwork ? game.artworks![index].url! : game.screenshots![index].url!),
        ),
        pageController: PageController(initialPage: index),
        enableRotation: true,
      ),
    );
  }
}