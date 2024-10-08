import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../igdb_models/game.dart';
import '../widgets/customDialog.dart';

class GameGridView extends StatelessWidget {
  final List<Game> collectionGames;
  final FirebaseUserModel? otherUserModel;
  final bool showRatedItems;
  final VoidCallback toggleRatedItemsVisibility;

  GameGridView({
    required this.collectionGames,
    this.otherUserModel,
    required this.showRatedItems,
    required this.toggleRatedItemsVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: .74,
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final game = collectionGames[index];
          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: GamePreviewView(
              game: game,
              isCover: true,
              buildContext: context,
              needsRating: true,
              isClickable: true,
              otherUserModel: otherUserModel,
              showRatedItem: showRatedItems,
            ),
          );
        },
        childCount: collectionGames.length,
      ),
    );
  }
}

class AllGamesGridScreen extends StatefulWidget {
  static Route route(List<Game> game, BuildContext context, String appBarText, FirebaseUserModel? otherUser) {
    return MaterialPageRoute(
      builder: (context) => AllGamesGridScreen(
        games: game,
        appBarText: appBarText,
        otherUserModel: otherUser,
      ),
    );
  }

  final List<Game> games;
  final String appBarText;
  FirebaseUserModel? otherUserModel;

  AllGamesGridScreen({required this.games, required this.appBarText, this.otherUserModel});

  @override
  _AllGamesGridScreenState createState() => _AllGamesGridScreenState();
}

class _AllGamesGridScreenState extends State<AllGamesGridScreen> {
  List<Game> sortedGames = [];
  String selectedSortOption = 'Rating';
  bool isAscending = true;
  bool showRatedItems = true;

  @override
  void initState() {
    sortedGames = List.from(widget.games);
    super.initState();
  }

  void sortGames(String sortBy) {
    setState(() {
      if (selectedSortOption == sortBy) {
        isAscending = !isAscending;
      } else {
        isAscending = true;
        selectedSortOption = sortBy;
      }
      switch (sortBy) {
        case 'Rating':
          sortedGames.sort((a, b) {
            final ratingA = a.totalRating ?? double.negativeInfinity;
            final ratingB = b.totalRating ?? double.negativeInfinity;
            return isAscending ? ratingA.compareTo(ratingB) : ratingB.compareTo(ratingA);
          });
          break;
        case 'My Rating':
          sortedGames.sort((a, b) {
            final ratingA = a.gameModel.rating;
            final ratingB = b.gameModel.rating;
            return isAscending ? ratingA.compareTo(ratingB) : ratingB.compareTo(ratingA);
          });
          break;
        case 'Name':
          sortedGames.sort((a, b) {
            final nameA = a.name ?? '';
            final nameB = b.name ?? '';
            return isAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
          });
          break;
        case 'Release Date':
          sortedGames.sort((a, b) {
            final releaseDateA = a.firstReleaseDate;
            final releaseDateB = b.firstReleaseDate;
            if (releaseDateA == null && releaseDateB == null) return 0;
            if (releaseDateA == null) return isAscending ? 1 : -1;
            if (releaseDateB == null) return isAscending ? -1 : 1;
            return isAscending ? releaseDateA.compareTo(releaseDateB) : releaseDateB.compareTo(releaseDateA);
          });
          break;
      }
    });
  }

  void toggleRatedItemsVisibility() {
    setState(() {
      showRatedItems = !showRatedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text(widget.appBarText)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showSortOptionsDialog(context);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          GameGridView(
            collectionGames: sortedGames,
            otherUserModel: widget.otherUserModel,
            showRatedItems: showRatedItems,
            toggleRatedItemsVisibility: toggleRatedItemsVisibility, // Pass the callback function
          ),
        ],
      ),
    );
  }

  void showSortOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Sort by',
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildSortButton('Rating', setState),
                  buildSortButton('My Rating', setState),
                  buildSortButton('Name', setState),
                  buildSortButton('Release Date', setState),
                  buildVisibilityButton(setState),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget buildSortButton(String sortBy, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GlassContainer(
        blur: 10,
        color: Theme.of(context).colorScheme.background.withOpacity(.8),
        child: TextButton(
          onPressed: () {
            setState(() {
              sortGames(sortBy);
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedSortOption == sortBy ? ' $sortBy' : sortBy,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: selectedSortOption == sortBy
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              GlassContainer(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(90),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    size: selectedSortOption == sortBy
                        ? 30 : 20,
                    color: Theme.of(context).colorScheme.onTertiary,
                    selectedSortOption == sortBy
                        ? (isAscending ? Icons.arrow_upward : Icons.arrow_downward)
                        : Icons.arrow_upward,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVisibilityButton(StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GlassContainer(
        blur: 10,
        color: Theme.of(context).colorScheme.background.withOpacity(.8),
        child: TextButton(
          onPressed: () {
            setState(() {
              toggleRatedItemsVisibility(); // Call the function to toggle visibility
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                showRatedItems ? 'Rated items are visible' : 'Rated items are not visible',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              GlassContainer(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(90),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    color: Theme.of(context).colorScheme.onTertiary,
                    showRatedItems
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

