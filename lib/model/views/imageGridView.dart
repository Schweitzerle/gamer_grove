import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../igdb_models/game.dart';
import '../widgets/photo_view.dart';

class ImageGridScreen extends StatelessWidget {
  final Game game;
  final bool isArtwork;

  ImageGridScreen({super.key, required this.game, required this.isArtwork});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArtwork ? "Artworks" : "Screenshots"),
      ),
      body: MasonryGridView.count(
        crossAxisCount: 2,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(1),
        itemCount: isArtwork ? game.artworks?.length : game.screenshots?.length,
        itemBuilder: ((context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoView(
                        game: game,
                        index: index,
                        isArtwork: isArtwork,
                      ),
                    ),
                  ),
                  child: Hero(
                    tag: isArtwork
                        ? game.artworks![index].url!
                        : game.screenshots![index].url!,
                    child: CachedNetworkImage(
                      imageUrl: isArtwork
                          ? game.artworks![index].url!
                          : game.screenshots![index].url!,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
          );
        }),
      ),
    );
  }
}
