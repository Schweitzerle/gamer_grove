import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/features/home/home_screen.dart';
import 'package:gamer_grove/model/igdb_models/collection.dart';
import 'package:gamer_grove/model/igdb_models/franchise.dart';
import 'package:gamer_grove/model/views/allGamesGridView.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';

import '../igdb_models/game.dart';

class FranchiseView extends StatelessWidget {
  final Franchise franchise;
  final Color colorPalette;
  const FranchiseView({Key? key, required this.franchise, required this.colorPalette}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    final List<Game> randGames = franchise.games!.toList()..shuffle();
    final List<Game> selectedGames = randGames.take(5).toList();

    return ClayContainer(
      spread: 2,
      depth: 60,
      borderRadius: 14,
      color: Theme.of(context).colorScheme.surface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Game previews
            ...List.generate(
              franchise.games!.length > 5 ? 5 : franchise.games!.length,
                  (index) {
                final topOffset = index == 0 ? 0.0 : (mediaHeight * .015) * index;
                final rightOffset = index == 0 ? 0.0 : (mediaWidth * .14) * index;
                return Positioned(
                  top: topOffset,
                  left: rightOffset,
                  child: Transform.scale(
                    alignment: Alignment.topLeft,
                    scale: .4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: GamePreviewView(
                        game: selectedGames[index],
                        isCover: true,
                        buildContext: context,
                      ),
                    ),
                  ),
                );
              },
            ),
            // ClayContainer for the "Collection" text
            Positioned(
              top: 8, // Adjust the top position to align with the top of the container
              right: 8, // Adjust the right position to align with the right of the container
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(AllGamesGridScreen.route(franchise.games!, context, franchise.name!));
                },
                child: ClayContainer(
                  spread: 2,
                  depth: 60,
                  borderRadius: 14,
                  color: colorPalette,
                  child: Padding(
                    padding: const EdgeInsets.all( 6),
                    child: Row(
                      children: [
                        Text(
                          'Franchise',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.navigate_next_rounded)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
