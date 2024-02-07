import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/features/searchScreen/search_screen.dart';
import 'package:gamer_grove/model/views/imageGridView.dart';
import 'package:gamer_grove/model/widgets/photo_view.dart';

import '../igdb_models/game.dart';

class ImagePreview extends StatelessWidget {
  final Game game;
  final bool isArtwork;

  ImagePreview({super.key, required this.game, required this.isArtwork});

  //TODO:Falls 4 fehler behebung, bsp. Foamstars: Season 1

  @override
  Widget build(BuildContext context) {
    // Check if artworks list is not null
    if (isArtwork ? game.artworks != null : game.screenshots != null) {
      int maxArtworksToShow = 5;
      int numArtworksToShow = isArtwork
          ? game.artworks!.length
          : game.screenshots!.length > maxArtworksToShow
              ? maxArtworksToShow
              : isArtwork
                  ? game.artworks!.length
                  : game.screenshots!.length;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClayContainer(
              spread: 2,
              customBorderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  isArtwork ? 'Artworks' : 'Screenshots',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).cardTheme.surfaceTintColor),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            // Display the first artwork covering the whole width
            if (numArtworksToShow > 0)
              AspectRatio(
                aspectRatio: 16 / 9, // Aspect ratio for the first artwork
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoView(
                        game: game,
                        index: 0,
                        isArtwork: isArtwork,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: isArtwork
                          ? game.artworks![0].url!
                          : game.screenshots![0]
                              .url!, // Replace with your image URL
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300], // Placeholder color
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 10), // Adjust spacing as needed
            // Display the next four artworks in a 2 by 2 arrangement
            if (numArtworksToShow > 1)
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      // Aspect ratio for the second artwork
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoView(
                              game: game,
                              index: 1,
                              isArtwork: isArtwork,
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: isArtwork
                                ? game.artworks![1].url!
                                : game.screenshots![1].url!,
                            // Replace with your image URL
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300], // Placeholder color
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Adjust spacing as needed
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      // Aspect ratio for the second artwork
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoView(
                              game: game,
                              index: 2,
                              isArtwork: isArtwork,
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: isArtwork
                                ? game.artworks![2].url!
                                : game.screenshots![2].url!,
                            // Replace with your image URL
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300], // Placeholder color
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 10), // Adjust spacing as needed
            if (numArtworksToShow > 3)
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 16 / 9, // Aspect ratio for the fifth artwork
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoView(
                              game: game,
                              index: 3,
                              isArtwork: isArtwork,
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: isArtwork
                                ? game.artworks![3].url!
                                : game.screenshots![3].url!,
                            // Replace with your image URL
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300], // Placeholder color
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Adjust spacing as needed

                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      // Aspect ratio for the fourth artwork
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to another screen when the last artwork is tapped
                          if (isArtwork
                              ? game.artworks!.length > maxArtworksToShow
                              : game.screenshots!.length > maxArtworksToShow) {
                            // Add your navigation logic here
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImageGridScreen(
                                      game: game, isArtwork: isArtwork)),
                            );
                          }
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                imageUrl: isArtwork
                                    ? game.artworks![4].url!
                                    : game.screenshots![4].url!,
                                // Replace with your image URL
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300], // Placeholder color
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (isArtwork
                                ? game.artworks!.length > maxArtworksToShow
                                : game.screenshots!.length > maxArtworksToShow)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                    child: Text(
                                      'All Artworks',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    } else {
      // Handle case when artworks list is null
      return Container(
        child: Text(
          'No artworks available for preview.',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }
  }
}
